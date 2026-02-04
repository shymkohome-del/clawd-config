#!/usr/bin/env node
/**
 * Job Detective - Djinni Flutter Monitor (Auto-Notify Edition)
 * Скрипт для моніторингу Flutter вакансій з автоматичними сповіщеннями
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

// Конфігурація
const CONFIG = {
  searchUrl: 'https://djinni.co/jobs/?primary_keyword=Flutter&employment=remote,office',
  dataDir: '/Users/vitaliisimko/clawd',
  telegramChatId: null // Потрібно заповнити для надсилання повідомлень
};

const PATHS = {
  seenJobs: path.join(CONFIG.dataDir, 'SEEN_JOBS.json'),
  jobLog: path.join(CONFIG.dataDir, 'JOB_LOG.md'),
  notifyLog: path.join(CONFIG.dataDir, 'NOTIFY_QUEUE.json')
};

// Завантажує HTML
async function fetchPage(url) {
  return new Promise((resolve) => {
    const cmd = `curl -s -L "${url}" \
      -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
      -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
      -H "Accept-Language: uk,en-US;q=0.7,en;q=0.3" \
      --compressed`;
    
    exec(cmd, { maxBuffer: 10 * 1024 * 1024 }, (error, stdout) => {
      resolve(error ? null : stdout);
    });
  });
}

// Парсить вакансії з JSON-LD
function parseJobs(html) {
  const jobs = [];
  const jsonLdRegex = /<script type="application\/ld\+json">([\s\S]*?)<\/script>/g;
  
  let match;
  while ((match = jsonLdRegex.exec(html)) !== null) {
    try {
      const data = JSON.parse(match[1]);
      const jobPostings = Array.isArray(data) ? data : [data];
      
      for (const job of jobPostings) {
        if (job['@type'] === 'JobPosting') {
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
            if (country) location = country;
          }
          
          const months = job.experienceRequirements?.monthsOfExperience;
          const experience = months ? `${Math.round(months / 12)}+ років` : 'Не вказано';
          
          jobs.push({
            id: String(job.identifier),
            title: job.title,
            company: job.hiringOrganization?.name || 'Невідомо',
            location: location,
            experience: experience,
            url: job.url,
            datePosted: job.datePosted,
            firstSeen: new Date().toISOString(),
          });
        }
      }
    } catch (e) {}
  }
  
  return jobs;
}

// Завантажує бачені вакансії
function loadSeenJobs() {
  try {
    return JSON.parse(fs.readFileSync(PATHS.seenJobs, 'utf8'));
  } catch {
    return { seenJobs: [], lastCheck: null, totalFound: 0, totalNew: 0 };
  }
}

// Зберігає бачені вакансії
function saveSeenJobs(data) {
  fs.writeFileSync(PATHS.seenJobs, JSON.stringify(data, null, 2));
}

// Форматує повідомлення
function formatJobMessage(job) {
  return `🎯 НОВА ВАКАНСІЯ!

🏢 Компанія: ${job.company}
💼 Позиція: ${job.title}
📍 Локація: ${job.location}
📊 Досвід: ${job.experience}

🔗 Лінк: ${job.url}`;
}

// Додає вакансію в чергу сповіщень
function queueNotification(job) {
  let queue = [];
  try {
    queue = JSON.parse(fs.readFileSync(PATHS.notifyLog, 'utf8'));
  } catch {}
  
  queue.push({
    job: job,
    timestamp: new Date().toISOString(),
    sent: false
  });
  
  fs.writeFileSync(PATHS.notifyLog, JSON.stringify(queue, null, 2));
}

// Головна функція
async function monitor() {
  const timestamp = new Date().toLocaleString('uk-UA');
  console.log(`\n🔍 [${timestamp}] Job Detective сканує Djinni...`);
  
  const html = await fetchPage(CONFIG.searchUrl);
  if (!html) {
    console.log('❌ Не вдалося завантажити сторінку');
    return [];
  }
  
  const currentJobs = parseJobs(html);
  console.log(`📋 Знайдено ${currentJobs.length} вакансій`);
  
  const data = loadSeenJobs();
  const seenIds = new Set(data.seenJobs.map(j => j.id));
  
  const newJobs = [];
  for (const job of currentJobs) {
    if (!seenIds.has(job.id)) {
      newJobs.push(job);
      data.seenJobs.push(job);
      queueNotification(job);
      console.log(`🆕 НОВА: ${job.title} | ${job.company}`);
    }
  }
  
  data.lastCheck = new Date().toISOString();
  data.totalFound = currentJobs.length;
  data.totalNew += newJobs.length;
  saveSeenJobs(data);
  
  console.log(`✅ Сканування завершено! Нових: ${newJobs.length}`);
  
  if (newJobs.length > 0) {
    console.log('\n=== НОВІ ВАКАНСІЇ ===');
    for (const job of newJobs) {
      console.log(formatJobMessage(job));
      console.log('---');
    }
  }
  
  return newJobs;
}

// Запуск
monitor().catch(console.error);
