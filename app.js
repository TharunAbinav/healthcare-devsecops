'use strict';
// Demo "Patient Records API". ALL DATA IS SYNTHETIC. Never put real patient data in a demo.
const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const crypto = require('crypto');

const app = express();
const PORT = 3000;
const API_KEY = process.env.API_KEY || '';   // injected from a Kubernetes Secret, never from code

if (API_KEY.length < 16) {
  console.error(JSON.stringify({ level: 'fatal', msg: 'API_KEY missing or too short' }));
  process.exit(1);
}

// Synthetic records
const PATIENTS = new Map([
  ['1', { id: 1, name: 'Asha Verma',   dob: '1984-03-12', diagnosis: 'Type 2 Diabetes', ward: 'Endocrinology' }],
  ['2', { id: 2, name: 'Rahul Menon',  dob: '1971-11-02', diagnosis: 'Hypertension',    ward: 'Cardiology'    }],
  ['3', { id: 3, name: 'Priya Nair',   dob: '1992-07-25', diagnosis: 'Asthma',          ward: 'Pulmonology'   }],
]);

// Data minimisation: the list view never exposes full names or diagnoses
function maskName(name) {
  return name.split(' ').map(p => p[0] + '*'.repeat(Math.max(p.length - 1, 1))).join(' ');
}

// Security headers (CSP, HSTS, no-sniff, no x-powered-by, ...)
app.use(helmet());

// Brute-force / scraping protection
app.use(rateLimit({ windowMs: 60 * 1000, limit: 100, standardHeaders: 'draft-7', legacyHeaders: false }));

// Audit log: who/what/when/result. Deliberately contains NO patient data.
app.use((req, res, next) => {
  res.on('finish', () => {
    console.log(JSON.stringify({
      ts: new Date().toISOString(), ip: req.ip, method: req.method,
      path: req.path, status: res.statusCode,
    }));
  });
  next();
});

// Authentication (constant-time comparison)
function requireApiKey(req, res, next) {
  const provided = Buffer.from(String(req.get('x-api-key') || ''));
  const expected = Buffer.from(API_KEY);
  const ok = provided.length === expected.length && crypto.timingSafeEqual(provided, expected);
  if (!ok) return res.status(401).json({ error: 'unauthorized' });
  return next();
}

app.get('/', (req, res) => {
  res.json({ service: 'healthcare-api', note: 'synthetic demo data only', endpoints: ['/health', '/api/patients', '/api/patients/:id'] });
});

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.get('/api/patients', requireApiKey, (req, res) => {
  const list = [...PATIENTS.values()].map(p => ({ id: p.id, name: maskName(p.name), ward: p.ward }));
  res.json(list);
});

app.get('/api/patients/:id', requireApiKey, (req, res) => {
  // Input validation: digits only, max 6 chars
  if (!/^[0-9]{1,6}$/.test(req.params.id)) return res.status(400).json({ error: 'invalid id' });
  const patient = PATIENTS.get(req.params.id);
  if (!patient) return res.status(404).json({ error: 'not found' });
  return res.json(patient);
});

app.use((req, res) => res.status(404).json({ error: 'not found' }));
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => res.status(500).json({ error: 'internal error' })); // never leak stack traces

app.listen(PORT, () => console.log(JSON.stringify({ level: 'info', msg: `listening on ${PORT}` })));
