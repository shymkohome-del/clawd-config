#!/usr/bin/env node
/**
 * Job Detective - Djinni Flutter Monitor
 * Скрипт для моніторингу Flutter вакансій на Djinni.co
 * 
 * Використання: node djinni_monitor.js
 */

const fs = require('fs');
const path = require('path');

// Конфігурація
const CONFIG = {
  searchUrl: 'https://djinni.co/jobs/?primary_keyword=Flutter&employment=remote,office',
  checkIntervalMinutes: 30,
  dataDir: __dirname
};

// Шляхи до файлів
const PATHS = {
  seenJobs: path.join(CONFIG.dataDir, 'SEEN_JOBS.json'),
  jobLog: path.join(CONFIG.dataDir, 'JOB_LOG.md'),
  config: path.join(CONFIG.dataDir, 'JOB_CONFIG.md')
};

/**
 * Завантажує HTML сторінку через curl
 */
async function fetchPage(url) {
  return new Promise((resolve, reject) => {
    const { exec } = require('child_process');
    const cmd = `curl -s -L "${url}" \
      -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
      -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
      -H "Accept-Language: uk,en-US;q=0.7,en;q=0.3" \
      --compressed`;
    
    exec(cmd, { maxBuffer: 10 * 1024 * 1024 }, (error, stdout, stderr) => {
      if (error) {
        console.error('Помилка curl:', error.message);
        resolve(null);
      } else {
        resolve(stdout);
      }
    });
  });
}

/**
 * Парсить вакансії з JSON-LD в HTML
 */
function parseJobs(html) {
  const jobs = [];
  
  // Шукаємо JSON-LD з JobPosting
  const jsonLdRegex = /<script type="application\/ld\+json">([\s\S]*?)<\/script>/g;
  
  let match;
  while ((match = jsonLdRegex.exec(html)) !== null) {
    try {
      const data = JSON.parse(match[1]);
      
      // Може бути масив або один об'єкт
      const jobPostings = Array.isArray(data) ? data : [data];
      
      for (const job of jobPostings) {
        if (job['@type'] === 'JobPosting') {
          // Визначаємо локацію
          let location = 'Не вказано';
          if (job.jobLocationType === 'TELECOMMUTE') {
            location = 'Remote';
            if (job.applicantLocationRequirements?.address?.addressRegion === 'Europe') {
              location = 'Remote, Європа';
            } else if (job.applicantLocationRequirements?.address?.addressCountry === 'UA') {
              location = 'Remote, Україна';
            }
          } else if (job.jobLocation) {
            const loc = Array.isArray(job.jobLocation) ? job.jobLocation[0] : job.jobLocation;
            const country = loc.address?.addressCountry;
            if (country) {
              location = country;
            }
          }
          
          // Досвід у роках
          const months = job.experienceRequirements?.monthsOfExperience;
          const experience = months ? `${Math.round(months / 12)}+ років` : 'Не вказано';
          
          // Компанія
          const company = job.hiringOrganization?.name || 'Невідомо';
          
          jobs.push({
            id: String(job.identifier),
            title: job.title,
            company: company,
            location: location,
            experience: experience,
            english: 'B1+', // Типово для Flutter вакансій
            salary: 'Не вказано', // ЗП рідко вказують
            url: job.url,
            datePosted: job.datePosted,
            firstSeen: new Date().toISOString(),
            status: 'active'
          });
        }
      }
    } catch (e) {
      // Ігноруємо помилки парсингу JSON
    }
  }
  
  return jobs;
}

/**
 * Завантажує бачені вакансії
 */
function loadSeenJobs() {
  try {
    const data = fs.readFileSync(PATHS.seenJobs, 'utf8');
    return JSON.parse(data);
  } catch {
    return { seenJobs: [], lastCheck: null, totalFound: 0, totalNew: 0 };
  }
}

/**
 * Зберігає бачені вакансії
 */
function saveSeenJobs(data) {
  fs.writeFileSync(PATHS.seenJobs, JSON.stringify(data, null, 2));
}

/**
 * Додає запис в лог
 */
function logJob(job, isNew) {
  const timestamp = new Date().toISOString().slice(0, 16).replace('T', ' ');
  const status = isNew ? '**[NEW]**' : '[seen]';
  const entry = `- ${timestamp} ${status} ${job.title} | ${job.company} | ${job.location}\n`;
  
  fs.appendFileSync(PATHS.jobLog, entry);
}

/**
 * Форматує повідомлення про нову вакансію
 */
function formatJobMessage(job) {
  return `
🎯 НОВА ВАКАНСІЯ!

🏢 Компанія: ${job.company}
💼 Позиція: ${job.title}
📍 Локація: ${job.location}
💰 ЗП: ${job.salary}
📊 Досвід: ${job.experience}
🌐 Англійська: ${job.english}

🔗 Лінк: ${job.url}
`;
}

/**
 * Головна функція моніторингу
 */
async function monitor() {
  console.log('🔍 Job Detective: Починаю сканування Djinni...');
  console.log(`📡 URL: ${CONFIG.searchUrl}`);
  console.log(`⏰ Час: ${new Date().toLocaleString('uk-UA')}`);
  console.log('');
  
  // Завантажуємо сторінку
  const html = await fetchPage(CONFIG.searchUrl);
  if (!html) {
    console.error('❌ Не вдалося завантажити сторінку');
    process.exit(1);
  }
  
  // Парсимо вакансії
  const currentJobs = parseJobs(html);
  console.log(`📋 Знайдено ${currentJobs.length} вакансій на сторінці`);
  
  // Завантажуємо історію
  const data = loadSeenJobs();
  const seenIds = new Set(data.seenJobs.map(j => j.id));
  
  // Шукаємо нові
  const newJobs = [];
  for (const job of currentJobs) {
    if (!seenIds.has(job.id)) {
      newJobs.push(job);
      data.seenJobs.push(job);
      logJob(job, true);
      console.log('🆕 НОВА:', job.title, '|', job.company);
    } else {
      console.log('👀 Вже бачили:', job.title);
    }
  }
  
  // Оновлюємо статистику
  data.lastCheck = new Date().toISOString();
  data.totalFound = currentJobs.length;
  data.totalNew += newJobs.length;
  
  // Зберігаємо
  saveSeenJobs(data);
  
  console.log('');
  console.log('✅ Сканування завершено!');
  console.log(`📊 Нових вакансій: ${newJobs.length}`);
  console.log(`📁 Всього в базі: ${data.seenJobs.length}`);
  
  // Виводимо нові для main agent
  if (newJobs.length > 0) {
    console.log('');
    console.log('=== НОВІ ВАКАНСІЇ ===');
    for (const job of newJobs) {
      console.log(formatJobMessage(job));
    }
  }
  
  return newJobs;
}

// Запуск
if (require.main === module) {
  monitor().catch(console.error);
}

module.exports = { monitor, parseJobs };
