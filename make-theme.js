#!/usr/bin/env node
// make-theme.js — apply an accent-colored theme to a VS Code settings.json.
// Generates `workbench.colorCustomizations` + `editor.tokenColorCustomizations` from a single accent
// color and merges them into the given settings.json (non-destructive: layers on top of whatever base
// theme you use; back up settings.json first — the installer does this for you).
//
// Usage: node make-theme.js <#RRGGBB> <path/to/settings.json>
'use strict';
const fs = require('fs');

const accent = (process.argv[2] || '').trim();
const settingsPath = process.argv[3];
if (!/^#?[0-9a-fA-F]{6}$/.test(accent) || !settingsPath) {
  console.error('usage: node make-theme.js <#RRGGBB> <settings.json>');
  process.exit(2);
}
const hex = accent.replace('#', '').toUpperCase();
const A = '#' + hex;

const clamp = (n) => Math.max(0, Math.min(255, Math.round(n)));
const toHex = (v) => clamp(v).toString(16).padStart(2, '0');
function mix(h, target, amt) {
  const r = parseInt(h.slice(0, 2), 16), g = parseInt(h.slice(2, 4), 16), b = parseInt(h.slice(4, 6), 16);
  return ('#' + toHex(r + (target - r) * amt) + toHex(g + (target - g) * amt) + toHex(b + (target - b) * amt)).toUpperCase();
}
const lighten = (amt) => mix(hex, 255, amt);
const hover = lighten(0.18);
// Readable foreground on top of the accent (black on light accents, white on dark ones).
const lum = (parseInt(hex.slice(0, 2), 16) * 0.299 + parseInt(hex.slice(2, 4), 16) * 0.587 + parseInt(hex.slice(4, 6), 16) * 0.114);
const on = lum > 150 ? '#000000' : '#FFFFFF';
const al = (suffix) => A + suffix; // accent with alpha

const colors = {
  'focusBorder': A,
  'editorCursor.foreground': A,
  'editor.selectionBackground': al('40'),
  'editorLineNumber.activeForeground': A,
  'activityBar.foreground': A,
  'activityBar.activeBorder': A,
  'activityBarBadge.background': A,
  'activityBarBadge.foreground': on,
  'sideBarTitle.foreground': A,
  'tab.activeForeground': A,
  'tab.activeBorderTop': A,
  'button.background': A,
  'button.foreground': on,
  'button.hoverBackground': hover,
  'badge.background': A,
  'badge.foreground': on,
  'progressBar.background': A,
  'list.activeSelectionForeground': A,
  'list.highlightForeground': A,
  'panelTitle.activeForeground': A,
  'panelTitle.activeBorder': A,
  'textLink.foreground': A,
  'textLink.activeForeground': hover,
  'scrollbarSlider.background': al('30'),
  'scrollbarSlider.hoverBackground': al('60'),
  'scrollbarSlider.activeBackground': al('80'),
  'minimap.selectionHighlight': al('60'),
};
const tokens = {
  'keywords': A,
  'functions': hover,
  'types': lighten(0.25),
  'numbers': lighten(0.3),
  'strings': lighten(0.4),
};

let s = {};
if (fs.existsSync(settingsPath)) {
  const t = fs.readFileSync(settingsPath, 'utf8').replace(/^﻿/, '');
  if (t.trim()) {
    try { s = JSON.parse(t); }
    catch (e) { console.log('  [warn] ' + settingsPath + ' is not plain JSON (comments?); skipping theme.'); process.exit(0); }
  }
}
s['workbench.colorCustomizations'] = Object.assign({}, s['workbench.colorCustomizations'] || {}, colors);
s['editor.tokenColorCustomizations'] = Object.assign({}, s['editor.tokenColorCustomizations'] || {}, tokens);
fs.writeFileSync(settingsPath, JSON.stringify(s, null, 4));
console.log('  [ok] accent ' + A + ' applied -> ' + settingsPath);
