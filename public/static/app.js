/* =========================================================================
   تطبيق الواجهة - المحاسب المحترف
   ========================================================================= */

const E = window.AccountingEngine;

// ============ حالة التطبيق ============
const STATE = {
  currentSection: 'home',
  entries: [],          // قيود اليومية للمستخدم
  nextEntryId: 1,
  openingBalances: {},
  scenarioName: '',     // اسم السيناريو/التمرين الحالي
};

// ============ تبديل الأقسام ============
function showSection(id) {
  document.querySelectorAll('.page-section').forEach(s => s.classList.remove('active'));
  const target = document.getElementById(id);
  if (target) target.classList.add('active');
  document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
  const navLink = document.querySelector(`.nav-link[data-target="${id}"]`);
  if (navLink) navLink.classList.add('active');
  STATE.currentSection = id;
  window.scrollTo({ top: 0, behavior: 'smooth' });
  if (id === 'lab') renderLab();
  if (id === 'ratios-calc') renderRatiosCalc();
}

window.addEventListener('hashchange', () => {
  const id = location.hash.slice(1) || 'home';
  showSection(id);
});

// ============ القيود والتمارين الجاهزة ============
const SCENARIOS = {
  empty: {
    name: 'تمرين فارغ',
    description: 'ابدأ من الصفر بإدخال قيودك.',
    entries: []
  },
  startup: {
    name: 'شركة ناشئة - الشهر الأول',
    description: 'مؤسسة تجارية تبدأ نشاطها: تأسيس، قرض، شراء أصول، بضاعة، مبيعات ومصروفات.',
    entries: [
      { date: '2024-01-01', description: 'تأسيس الشركة - إيداع رأس المال في البنك', lines: [
        { accountCode: '1102', debit: 300000, credit: 0 },
        { accountCode: '3101', debit: 0, credit: 300000 }
      ]},
      { date: '2024-01-03', description: 'الحصول على قرض طويل الأجل من البنك', lines: [
        { accountCode: '1102', debit: 100000, credit: 0 },
        { accountCode: '2201', debit: 0, credit: 100000 }
      ]},
      { date: '2024-01-05', description: 'شراء سيارة نقل بالشيك', lines: [
        { accountCode: '1506', debit: 80000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 80000 }
      ]},
      { date: '2024-01-06', description: 'شراء أثاث مكتبي نقداً', lines: [
        { accountCode: '1508', debit: 25000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 25000 }
      ]},
      { date: '2024-01-10', description: 'شراء بضاعة نقداً', lines: [
        { accountCode: '1301', debit: 120000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 120000 }
      ]},
      { date: '2024-01-12', description: 'شراء بضاعة بالأجل من مورد', lines: [
        { accountCode: '1301', debit: 60000, credit: 0 },
        { accountCode: '2101', debit: 0, credit: 60000 }
      ]},
      { date: '2024-01-15', description: 'مبيعات نقدية', lines: [
        { accountCode: '1102', debit: 90000, credit: 0 },
        { accountCode: '4101', debit: 0, credit: 90000 }
      ]},
      { date: '2024-01-15', description: 'تكلفة البضاعة المباعة للبيع النقدي', lines: [
        { accountCode: '5101', debit: 55000, credit: 0 },
        { accountCode: '1301', debit: 0, credit: 55000 }
      ]},
      { date: '2024-01-20', description: 'مبيعات آجلة للعملاء', lines: [
        { accountCode: '1201', debit: 150000, credit: 0 },
        { accountCode: '4101', debit: 0, credit: 150000 }
      ]},
      { date: '2024-01-20', description: 'تكلفة البضاعة للمبيعات الآجلة', lines: [
        { accountCode: '5101', debit: 92000, credit: 0 },
        { accountCode: '1301', debit: 0, credit: 92000 }
      ]},
      { date: '2024-01-25', description: 'سداد مرتبات الموظفين', lines: [
        { accountCode: '5301', debit: 18000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 18000 }
      ]},
      { date: '2024-01-26', description: 'إيجار المحل', lines: [
        { accountCode: '5302', debit: 6000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 6000 }
      ]},
      { date: '2024-01-27', description: 'فاتورة الكهرباء', lines: [
        { accountCode: '5303', debit: 1500, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 1500 }
      ]},
      { date: '2024-01-28', description: 'تحصيل جزء من العملاء', lines: [
        { accountCode: '1102', debit: 60000, credit: 0 },
        { accountCode: '1201', debit: 0, credit: 60000 }
      ]},
      { date: '2024-01-29', description: 'سداد دفعة للموردين', lines: [
        { accountCode: '2101', debit: 40000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 40000 }
      ]},
      { date: '2024-01-30', description: 'فائدة القرض المستحقة', lines: [
        { accountCode: '5401', debit: 800, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 800 }
      ]},
      { date: '2024-01-31', description: 'إهلاك الأصول الثابتة للشهر (سيارة+أثاث)', lines: [
        { accountCode: '5306', debit: 1500, credit: 0 },
        { accountCode: '1507', debit: 0, credit: 1100 }, // مجمع إهلاك سيارات (80,000 × 20%/12 ≈ 1,333 لكن نقرّب)
        { accountCode: '1509', debit: 0, credit: 400 }   // مجمع إهلاك أثاث (25,000 × 20%/12 ≈ 417 نقرّب)
      ]},
      { date: '2024-01-31', description: 'مصروف ضريبة الدخل (20%)', lines: [
        { accountCode: '5501', debit: 13040, credit: 0 },
        { accountCode: '2105', debit: 0, credit: 13040 }
      ]}
    ]
  },
  service: {
    name: 'شركة خدمات استشارية',
    description: 'شركة تقدم خدمات استشارية (بدون بضاعة/مخزون).',
    entries: [
      { date: '2024-01-01', description: 'تأسيس شركة الخدمات', lines: [
        { accountCode: '1102', debit: 150000, credit: 0 },
        { accountCode: '3101', debit: 0, credit: 150000 }
      ]},
      { date: '2024-01-03', description: 'شراء أجهزة حاسب وأثاث', lines: [
        { accountCode: '1508', debit: 30000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 30000 }
      ]},
      { date: '2024-01-05', description: 'دفع إيجار 6 أشهر مقدماً', lines: [
        { accountCode: '1401', debit: 24000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 24000 }
      ]},
      { date: '2024-01-10', description: 'تقديم خدمة استشارية نقداً', lines: [
        { accountCode: '1102', debit: 45000, credit: 0 },
        { accountCode: '4201', debit: 0, credit: 45000 }
      ]},
      { date: '2024-01-15', description: 'تقديم خدمات بالأجل', lines: [
        { accountCode: '1201', debit: 80000, credit: 0 },
        { accountCode: '4201', debit: 0, credit: 80000 }
      ]},
      { date: '2024-01-20', description: 'رواتب الموظفين', lines: [
        { accountCode: '5301', debit: 35000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 35000 }
      ]},
      { date: '2024-01-25', description: 'مصروفات اتصالات وإنترنت', lines: [
        { accountCode: '5304', debit: 2000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 2000 }
      ]},
      { date: '2024-01-31', description: 'إطفاء إيجار الشهر (24000/6)', lines: [
        { accountCode: '5302', debit: 4000, credit: 0 },
        { accountCode: '1401', debit: 0, credit: 4000 }
      ]},
      { date: '2024-01-31', description: 'إهلاك الأجهزة والأثاث (20% سنوياً / 12)', lines: [
        { accountCode: '5306', debit: 500, credit: 0 },
        { accountCode: '1509', debit: 0, credit: 500 }
      ]}
    ]
  },
  manufacturing: {
    name: 'شركة تجارية - أرباح قوية',
    description: 'شركة تجارية ناضجة بأرباح جيدة وهيكل مالي متوازن.',
    entries: [
      { date: '2024-01-01', description: 'رأس المال', lines: [
        { accountCode: '1102', debit: 500000, credit: 0 },
        { accountCode: '3101', debit: 0, credit: 500000 }
      ]},
      { date: '2024-01-01', description: 'أرباح محتجزة من السنوات السابقة', lines: [
        { accountCode: '1102', debit: 150000, credit: 0 },
        { accountCode: '3103', debit: 0, credit: 150000 }
      ]},
      { date: '2024-01-02', description: 'شراء أراضي', lines: [
        { accountCode: '1501', debit: 200000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 200000 }
      ]},
      { date: '2024-01-02', description: 'شراء مباني', lines: [
        { accountCode: '1502', debit: 180000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 180000 }
      ]},
      { date: '2024-01-03', description: 'شراء آلات ومعدات بالأجل', lines: [
        { accountCode: '1504', debit: 120000, credit: 0 },
        { accountCode: '2201', debit: 0, credit: 120000 }
      ]},
      { date: '2024-01-05', description: 'شراء بضاعة كبيرة', lines: [
        { accountCode: '1301', debit: 250000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 100000 },
        { accountCode: '2101', debit: 0, credit: 150000 }
      ]},
      { date: '2024-01-15', description: 'مبيعات نقدية وآجلة', lines: [
        { accountCode: '1102', debit: 200000, credit: 0 },
        { accountCode: '1201', debit: 300000, credit: 0 },
        { accountCode: '4101', debit: 0, credit: 500000 }
      ]},
      { date: '2024-01-15', description: 'تكلفة البضاعة المباعة', lines: [
        { accountCode: '5101', debit: 220000, credit: 0 },
        { accountCode: '1301', debit: 0, credit: 220000 }
      ]},
      { date: '2024-01-20', description: 'مردودات مبيعات (بضاعة معيبة)', lines: [
        { accountCode: '4102', debit: 15000, credit: 0 },
        { accountCode: '1201', debit: 0, credit: 15000 }
      ]},
      { date: '2024-01-25', description: 'مصاريف بيعية (إعلان وعمولات)', lines: [
        { accountCode: '5202', debit: 12000, credit: 0 },
        { accountCode: '5203', debit: 8000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 20000 }
      ]},
      { date: '2024-01-28', description: 'مصاريف إدارية', lines: [
        { accountCode: '5301', debit: 40000, credit: 0 },
        { accountCode: '5302', debit: 10000, credit: 0 },
        { accountCode: '5303', debit: 3000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 53000 }
      ]},
      { date: '2024-01-30', description: 'فوائد القرض', lines: [
        { accountCode: '5401', debit: 1000, credit: 0 },
        { accountCode: '1102', debit: 0, credit: 1000 }
      ]},
      { date: '2024-01-31', description: 'إهلاك شهري (مباني+آلات)', lines: [
        { accountCode: '5306', debit: 2500, credit: 0 },
        { accountCode: '1503', debit: 0, credit: 750 },   // مباني 180,000 × 5%/12
        { accountCode: '1505', debit: 0, credit: 1750 }   // آلات 120,000 × 17.5%/12
      ]},
      { date: '2024-01-31', description: 'ضريبة الدخل 20% تقريباً', lines: [
        { accountCode: '5501', debit: 33700, credit: 0 },
        { accountCode: '2105', debit: 0, credit: 33700 }
      ]}
    ]
  }
};

// ============ عرض المختبر (Lab) ============
function renderLab() {
  const container = document.getElementById('lab-container');
  if (!container) return;
  container.innerHTML = `
    <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-4 mb-4">
      <div class="flex flex-wrap items-center justify-between gap-3 mb-3">
        <div>
          <h3 class="text-xl font-black text-slate-800"><i class="fas fa-flask-vial ml-2 text-blue-600"></i>المختبر العملي</h3>
          <p class="text-sm text-slate-500 mt-1">${STATE.scenarioName ? 'السيناريو الحالي: <strong>' + STATE.scenarioName + '</strong>' : 'ابدأ بتحميل سيناريو جاهز أو أدخل قيودك يدوياً'}</p>
        </div>
        <div class="flex flex-wrap gap-2">
          <select id="scenario-select" class="input-field" style="width:auto; padding: 8px 14px;">
            <option value="">-- اختر سيناريو --</option>
            <option value="empty">فارغ (ابدأ من الصفر)</option>
            <option value="service">شركة خدمات استشارية</option>
            <option value="startup">شركة ناشئة - الشهر الأول</option>
            <option value="manufacturing">شركة تجارية - أرباح قوية</option>
          </select>
          <button onclick="loadScenario()" class="bg-blue-600 text-white px-4 py-2 rounded-lg font-bold hover:bg-blue-700 transition">
            <i class="fas fa-download ml-1"></i>تحميل
          </button>
          <button onclick="clearAll()" class="bg-red-600 text-white px-4 py-2 rounded-lg font-bold hover:bg-red-700 transition">
            <i class="fas fa-trash ml-1"></i>مسح الكل
          </button>
        </div>
      </div>
    </div>

    <!-- خطوات العمل -->
    <div class="step-indicator">
      <div class="step done"><i class="fas fa-pen"></i> ١. قيود اليومية</div>
      <i class="fas fa-chevron-left text-slate-400"></i>
      <div class="step done"><i class="fas fa-scale-balanced"></i> ٢. ميزان المراجعة</div>
      <i class="fas fa-chevron-left text-slate-400"></i>
      <div class="step done"><i class="fas fa-file-invoice-dollar"></i> ٣. قائمة الدخل</div>
      <i class="fas fa-chevron-left text-slate-400"></i>
      <div class="step done"><i class="fas fa-building"></i> ٤. المركز المالي</div>
      <i class="fas fa-chevron-left text-slate-400"></i>
      <div class="step done"><i class="fas fa-chart-line"></i> ٥. النسب المالية</div>
    </div>

    <!-- تبويبات -->
    <div class="bg-white rounded-2xl shadow-sm border border-slate-200">
      <div class="flex border-b border-slate-200 overflow-x-auto">
        <button class="tab-btn active" data-tab="tab-journal"><i class="fas fa-pen ml-1"></i>اليومية</button>
        <button class="tab-btn" data-tab="tab-tb"><i class="fas fa-scale-balanced ml-1"></i>ميزان المراجعة</button>
        <button class="tab-btn" data-tab="tab-is"><i class="fas fa-file-invoice-dollar ml-1"></i>قائمة الدخل</button>
        <button class="tab-btn" data-tab="tab-bs"><i class="fas fa-building ml-1"></i>المركز المالي</button>
        <button class="tab-btn" data-tab="tab-eq"><i class="fas fa-hand-holding-dollar ml-1"></i>التغيرات في حقوق الملكية</button>
        <button class="tab-btn" data-tab="tab-cf"><i class="fas fa-money-bill-transfer ml-1"></i>التدفقات النقدية</button>
        <button class="tab-btn" data-tab="tab-ratios"><i class="fas fa-chart-line ml-1"></i>التحليل المالي</button>
      </div>

      <div id="tab-journal" class="tab-content p-4"></div>
      <div id="tab-tb" class="tab-content p-4 hidden"></div>
      <div id="tab-is" class="tab-content p-4 hidden"></div>
      <div id="tab-bs" class="tab-content p-4 hidden"></div>
      <div id="tab-eq" class="tab-content p-4 hidden"></div>
      <div id="tab-cf" class="tab-content p-4 hidden"></div>
      <div id="tab-ratios" class="tab-content p-4 hidden"></div>
    </div>
  `;

  // إدارة التبويبات
  container.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      container.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      container.querySelectorAll('.tab-content').forEach(c => c.classList.add('hidden'));
      btn.classList.add('active');
      const target = document.getElementById(btn.dataset.tab);
      if (target) target.classList.remove('hidden');
      if (btn.dataset.tab === 'tab-tb') renderTrialBalance();
      if (btn.dataset.tab === 'tab-is') renderIncomeStatement();
      if (btn.dataset.tab === 'tab-bs') renderBalanceSheet();
      if (btn.dataset.tab === 'tab-eq') renderEquityChanges();
      if (btn.dataset.tab === 'tab-cf') renderCashFlow();
      if (btn.dataset.tab === 'tab-ratios') renderRatios();
    });
  });

  renderJournal();
}

function loadScenario() {
  const sel = document.getElementById('scenario-select');
  if (!sel || !sel.value) { alert('الرجاء اختيار سيناريو أولاً.'); return; }
  const s = SCENARIOS[sel.value];
  STATE.entries = s.entries.map((e, i) => ({
    id: i + 1,
    date: e.date,
    description: e.description,
    lines: JSON.parse(JSON.stringify(e.lines))
  }));
  STATE.nextEntryId = STATE.entries.length + 1;
  STATE.scenarioName = s.name;
  renderLab();
}

function clearAll() {
  if (!confirm('هل تريد حقاً مسح جميع القيود؟')) return;
  STATE.entries = [];
  STATE.nextEntryId = 1;
  STATE.scenarioName = '';
  renderLab();
}

// ============ تبويب اليومية ============
function renderJournal() {
  const container = document.getElementById('tab-journal');
  if (!container) return;
  const accountOptions = Object.keys(E.CHART_OF_ACCOUNTS).sort().map(code => {
    const a = E.CHART_OF_ACCOUNTS[code];
    return `<option value="${code}">${code} - ${a.name}</option>`;
  }).join('');

  container.innerHTML = `
    <div class="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-xl">
      <h4 class="font-bold text-blue-900 mb-2"><i class="fas fa-plus-circle ml-1"></i>إضافة قيد جديد</h4>
      <div class="grid grid-cols-1 md:grid-cols-4 gap-3 mb-3">
        <input type="date" id="new-date" class="input-field" value="${new Date().toISOString().slice(0,10)}" />
        <input type="text" id="new-desc" class="input-field md:col-span-3" placeholder="وصف القيد (مثال: مبيعات نقدية)" />
      </div>
      <div id="new-lines" class="space-y-2 mb-3">
        <div class="line-row grid grid-cols-12 gap-2 items-center">
          <select class="input-field col-span-6 acc-code">${accountOptions}</select>
          <input type="number" class="input-field col-span-3 amt-debit num" placeholder="مدين" step="0.01" min="0" />
          <input type="number" class="input-field col-span-3 amt-credit num" placeholder="دائن" step="0.01" min="0" />
        </div>
        <div class="line-row grid grid-cols-12 gap-2 items-center">
          <select class="input-field col-span-6 acc-code">${accountOptions}</select>
          <input type="number" class="input-field col-span-3 amt-debit num" placeholder="مدين" step="0.01" min="0" />
          <input type="number" class="input-field col-span-3 amt-credit num" placeholder="دائن" step="0.01" min="0" />
        </div>
      </div>
      <div class="flex flex-wrap items-center gap-2">
        <button onclick="addLineRow()" class="bg-slate-200 text-slate-700 px-3 py-2 rounded-lg font-bold hover:bg-slate-300"><i class="fas fa-plus ml-1"></i>سطر جديد</button>
        <button onclick="saveNewEntry()" class="bg-green-600 text-white px-4 py-2 rounded-lg font-bold hover:bg-green-700"><i class="fas fa-save ml-1"></i>حفظ القيد</button>
        <span id="new-entry-feedback" class="text-sm font-bold"></span>
      </div>
    </div>

    <div class="flex items-center justify-between mb-3">
      <h4 class="font-bold text-slate-800 text-lg"><i class="fas fa-book ml-1"></i>قيود اليومية (${STATE.entries.length} قيد)</h4>
      <div id="journal-balance-check" class="text-sm"></div>
    </div>

    <div id="journal-list" class="space-y-3"></div>
  `;

  renderJournalList();
}

function addLineRow() {
  const container = document.getElementById('new-lines');
  const accountOptions = Object.keys(E.CHART_OF_ACCOUNTS).sort().map(code => {
    const a = E.CHART_OF_ACCOUNTS[code];
    return `<option value="${code}">${code} - ${a.name}</option>`;
  }).join('');
  const div = document.createElement('div');
  div.className = 'line-row grid grid-cols-12 gap-2 items-center';
  div.innerHTML = `
    <select class="input-field col-span-5 acc-code">${accountOptions}</select>
    <input type="number" class="input-field col-span-3 amt-debit num" placeholder="مدين" step="0.01" min="0" />
    <input type="number" class="input-field col-span-3 amt-credit num" placeholder="دائن" step="0.01" min="0" />
    <button onclick="this.parentElement.remove()" class="col-span-1 text-red-600 hover:text-red-800"><i class="fas fa-times-circle text-xl"></i></button>
  `;
  container.appendChild(div);
}

function saveNewEntry() {
  const desc = document.getElementById('new-desc').value.trim();
  const date = document.getElementById('new-date').value;
  const feedback = document.getElementById('new-entry-feedback');
  if (!desc) { feedback.innerHTML = '<span class="text-red-600">يجب إدخال وصف القيد.</span>'; return; }

  const rows = document.querySelectorAll('#new-lines .line-row');
  const lines = [];
  rows.forEach(row => {
    const code = row.querySelector('.acc-code').value;
    const dr = parseFloat(row.querySelector('.amt-debit').value) || 0;
    const cr = parseFloat(row.querySelector('.amt-credit').value) || 0;
    if (dr > 0 || cr > 0) lines.push({ accountCode: code, debit: dr, credit: cr });
  });

  const entry = { id: STATE.nextEntryId++, date, description: desc, lines };
  const validation = E.validateJournalEntry(entry);
  if (!validation.valid) {
    feedback.innerHTML = `<span class="text-red-600">${validation.errors.join(' ')}</span>`;
    return;
  }

  STATE.entries.push(entry);
  feedback.innerHTML = `<span class="text-green-700">✓ تم حفظ القيد (إجمالي ${E.formatNum(validation.totalDr)})</span>`;
  setTimeout(() => renderJournal(), 600);
}

function deleteEntry(id) {
  if (!confirm('حذف هذا القيد؟')) return;
  STATE.entries = STATE.entries.filter(e => e.id !== id);
  renderJournal();
}

function renderJournalList() {
  const container = document.getElementById('journal-list');
  if (!container) return;
  if (STATE.entries.length === 0) {
    container.innerHTML = '<div class="text-center py-8 text-slate-500"><i class="fas fa-inbox text-4xl mb-3"></i><br>لا توجد قيود. ابدأ بإضافة قيد أو حمّل سيناريو جاهزاً.</div>';
    document.getElementById('journal-balance-check').innerHTML = '';
    return;
  }

  // التحقق من التوازن الكلي
  const tb = E.buildTrialBalance(STATE.entries);
  const bcheck = document.getElementById('journal-balance-check');
  if (tb.balanced) {
    bcheck.innerHTML = `<span class="badge badge-success"><i class="fas fa-check-circle ml-1"></i>جميع القيود متوازنة</span>`;
  } else {
    bcheck.innerHTML = `<span class="badge badge-danger"><i class="fas fa-exclamation-triangle ml-1"></i>عدم توازن! المدين ${E.formatNum(tb.totalDebit)} ≠ الدائن ${E.formatNum(tb.totalCredit)}</span>`;
  }

  container.innerHTML = STATE.entries.map((entry, idx) => {
    const totalDr = entry.lines.reduce((s, l) => s + (Number(l.debit) || 0), 0);
    return `
      <div class="border border-slate-200 rounded-xl bg-white overflow-hidden">
        <div class="bg-slate-50 px-4 py-2 flex items-center justify-between border-b border-slate-200">
          <div class="flex items-center gap-3">
            <span class="font-bold text-slate-600">#${idx + 1}</span>
            <span class="text-sm text-slate-500">${entry.date}</span>
            <span class="font-bold">${entry.description}</span>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-sm text-slate-500">الإجمالي: <span class="font-bold num">${E.formatNum(totalDr)}</span></span>
            <button onclick="deleteEntry(${entry.id})" class="text-red-600 hover:text-red-800"><i class="fas fa-trash"></i></button>
          </div>
        </div>
        <table class="fin-table">
          <thead>
            <tr><th>الحساب</th><th class="num-cell">مدين</th><th class="num-cell">دائن</th></tr>
          </thead>
          <tbody>
            ${entry.lines.map(l => {
              const acc = E.getAccount(l.accountCode);
              const name = acc ? `${l.accountCode} - ${acc.name}` : l.accountCode;
              return `<tr class="${l.debit > 0 ? 'je-debit' : 'je-credit'}">
                <td>${l.debit > 0 ? '' : '&nbsp;&nbsp;&nbsp;&nbsp;'}${name}</td>
                <td class="num-cell">${l.debit > 0 ? E.formatNum(l.debit) : '-'}</td>
                <td class="num-cell">${l.credit > 0 ? E.formatNum(l.credit) : '-'}</td>
              </tr>`;
            }).join('')}
          </tbody>
        </table>
      </div>
    `;
  }).join('');
}

// ============ تبويب ميزان المراجعة ============
function renderTrialBalance() {
  const container = document.getElementById('tab-tb');
  if (!container) return;
  if (STATE.entries.length === 0) { container.innerHTML = emptyState('لا توجد قيود لعرض ميزان المراجعة.'); return; }

  const tb = E.buildTrialBalance(STATE.entries, STATE.openingBalances);
  container.innerHTML = `
    <div class="mb-3 flex items-center justify-between flex-wrap gap-2">
      <h4 class="font-black text-slate-800 text-xl"><i class="fas fa-scale-balanced ml-2 text-blue-600"></i>ميزان المراجعة</h4>
      ${tb.balanced
        ? `<span class="badge badge-success text-base"><i class="fas fa-check-circle ml-1"></i>متوازن ✓</span>`
        : `<span class="badge badge-danger text-base"><i class="fas fa-exclamation-triangle ml-1"></i>غير متوازن!</span>`}
    </div>
    <div class="info-box text-sm mb-3">
      <strong>ميزان المراجعة</strong> هو قائمة بأرصدة جميع الحسابات الموجودة في الأستاذ العام. يجب أن يتساوى مجموع الأرصدة المدينة مع مجموع الأرصدة الدائنة تطبيقاً لمبدأ القيد المزدوج.
    </div>
    <div class="overflow-x-auto">
      <table class="fin-table">
        <thead>
          <tr>
            <th>الكود</th>
            <th>اسم الحساب</th>
            <th class="num-cell">حركة مدينة</th>
            <th class="num-cell">حركة دائنة</th>
            <th class="num-cell">رصيد مدين</th>
            <th class="num-cell">رصيد دائن</th>
          </tr>
        </thead>
        <tbody>
          ${tb.rows.map(r => `
            <tr>
              <td><code>${r.code}</code></td>
              <td>${r.name}${r.contra ? ' <span class="badge badge-warning text-xs">مقابل</span>' : ''}</td>
              <td class="num-cell text-slate-500">${r.debitMovement ? E.formatNum(r.debitMovement) : '-'}</td>
              <td class="num-cell text-slate-500">${r.creditMovement ? E.formatNum(r.creditMovement) : '-'}</td>
              <td class="num-cell font-bold text-blue-700">${r.balanceDr ? E.formatNum(r.balanceDr) : '-'}</td>
              <td class="num-cell font-bold text-red-700">${r.balanceCr ? E.formatNum(r.balanceCr) : '-'}</td>
            </tr>
          `).join('')}
          <tr class="grand-total">
            <td colspan="4">الإجمالي</td>
            <td class="num-cell">${E.formatNum(tb.totalDebit)}</td>
            <td class="num-cell">${E.formatNum(tb.totalCredit)}</td>
          </tr>
        </tbody>
      </table>
    </div>
    ${!tb.balanced ? `
      <div class="danger-box mt-3">
        <strong><i class="fas fa-exclamation-triangle"></i> تحذير:</strong>
        الفرق = ${E.formatNum(Math.abs(tb.totalDebit - tb.totalCredit))}. راجع قيود اليومية للتأكد من صحة المبالغ.
      </div>
    ` : ''}
  `;
}

// ============ تبويب قائمة الدخل ============
function renderIncomeStatement() {
  const container = document.getElementById('tab-is');
  if (!container) return;
  if (STATE.entries.length === 0) { container.innerHTML = emptyState('لا توجد قيود لعرض قائمة الدخل.'); return; }

  const tb = E.buildTrialBalance(STATE.entries, STATE.openingBalances);
  const is = E.buildIncomeStatement(tb);

  const rowLine = (label, value, cls = '') => `<tr class="${cls}"><td>${label}</td><td class="num-cell">${E.formatNum(value, { parens: true })}</td></tr>`;
  const rowHeader = (label) => `<tr class="section-header"><td colspan="2">${label}</td></tr>`;
  const rowSubtotal = (label, value) => `<tr class="subtotal"><td>${label}</td><td class="num-cell">${E.formatNum(value, { parens: true })}</td></tr>`;
  const rowGrand = (label, value) => `<tr class="grand-total"><td>${label}</td><td class="num-cell">${E.formatNum(value, { parens: true })}</td></tr>`;

  container.innerHTML = `
    <div class="mb-3 flex items-center justify-between flex-wrap gap-2">
      <h4 class="font-black text-slate-800 text-xl"><i class="fas fa-file-invoice-dollar ml-2 text-green-600"></i>قائمة الدخل (الأرباح والخسائر)</h4>
      <span class="badge ${is.netProfit >= 0 ? 'badge-success' : 'badge-danger'} text-base">
        صافي ${is.netProfit >= 0 ? 'الربح' : 'الخسارة'}: ${E.formatNum(Math.abs(is.netProfit))}
      </span>
    </div>
    <div class="info-box text-sm mb-3">
      <strong>قائمة الدخل</strong> تُظهر إيرادات ومصروفات الشركة خلال فترة محددة، وتنتهي بصافي الربح أو الخسارة.
      <strong>المعادلة:</strong> الإيرادات - المصروفات = صافي الربح.
    </div>

    <div class="overflow-x-auto">
      <table class="fin-table">
        <tbody>
          ${rowHeader('الإيرادات (Revenues)')}
          ${rowLine('إيرادات المبيعات', is.grossSales)}
          ${is.salesReturns ? rowLine('(-) مردودات ومسموحات المبيعات', -is.salesReturns) : ''}
          ${is.salesDiscounts ? rowLine('(-) الخصم المسموح به', -is.salesDiscounts) : ''}
          ${rowSubtotal('صافي الإيرادات', is.netSales)}

          ${rowHeader('تكلفة البضاعة المباعة (COGS)')}
          ${is.cogsComponents.cogsDirect ? rowLine('تكلفة البضاعة المباعة', is.cogsComponents.cogsDirect) : ''}
          ${is.cogsComponents.purchases ? rowLine('المشتريات', is.cogsComponents.purchases) : ''}
          ${is.cogsComponents.purchRet ? rowLine('(-) مردودات المشتريات', -is.cogsComponents.purchRet) : ''}
          ${is.cogsComponents.purchDisc ? rowLine('(-) خصم المشتريات المكتسب', -is.cogsComponents.purchDisc) : ''}
          ${is.cogsComponents.freightIn ? rowLine('مصروفات نقل المشتريات', is.cogsComponents.freightIn) : ''}
          ${rowSubtotal('إجمالي تكلفة البضاعة المباعة', is.cogs)}

          ${rowSubtotal('مجمل الربح (Gross Profit)', is.grossProfit)}

          ${is.sellingExp ? rowHeader('المصروفات البيعية') : ''}
          ${is.details.expenses.filter(e => e.sub === 'SELL').map(e => rowLine(`&nbsp;&nbsp;&nbsp;&nbsp;${e.name}`, e.balanceDr)).join('')}
          ${is.sellingExp ? rowSubtotal('إجمالي المصروفات البيعية', is.sellingExp) : ''}

          ${is.adminExp ? rowHeader('المصروفات الإدارية والعمومية') : ''}
          ${is.details.expenses.filter(e => e.sub === 'ADMIN').map(e => rowLine(`&nbsp;&nbsp;&nbsp;&nbsp;${e.name}`, e.balanceDr)).join('')}
          ${is.adminExp ? rowSubtotal('إجمالي المصروفات الإدارية', is.adminExp) : ''}

          ${rowSubtotal('الربح التشغيلي (Operating Profit)', is.operatingProfit)}

          ${is.otherIncome ? rowLine('(+) إيرادات أخرى', is.otherIncome) : ''}
          ${is.financeExp ? rowLine('(-) المصروفات التمويلية (فوائد)', -is.financeExp) : ''}
          ${is.otherExp ? rowLine('(-) خسائر أخرى', -is.otherExp) : ''}

          ${rowSubtotal('الربح قبل الضريبة', is.profitBeforeTax)}
          ${is.taxExp ? rowLine('(-) مصروف ضريبة الدخل', -is.taxExp) : ''}

          ${rowGrand(`صافي ${is.netProfit >= 0 ? 'الربح' : 'الخسارة'}`, is.netProfit)}
        </tbody>
      </table>
    </div>

    <div class="grid md:grid-cols-3 gap-3 mt-4">
      <div class="ratio-card">
        <div class="text-sm text-slate-500">هامش الربح الإجمالي</div>
        <div class="ratio-value ${is.netSales > 0 ? 'neutral' : 'bad'}">${is.netSales > 0 ? E.formatNum((is.grossProfit / is.netSales) * 100) + '%' : '--'}</div>
      </div>
      <div class="ratio-card">
        <div class="text-sm text-slate-500">هامش الربح التشغيلي</div>
        <div class="ratio-value ${is.netSales > 0 ? 'neutral' : 'bad'}">${is.netSales > 0 ? E.formatNum((is.operatingProfit / is.netSales) * 100) + '%' : '--'}</div>
      </div>
      <div class="ratio-card">
        <div class="text-sm text-slate-500">هامش صافي الربح</div>
        <div class="ratio-value ${is.netSales > 0 && is.netProfit > 0 ? 'good' : 'bad'}">${is.netSales > 0 ? E.formatNum((is.netProfit / is.netSales) * 100) + '%' : '--'}</div>
      </div>
    </div>
  `;
}

// ============ تبويب قائمة المركز المالي ============
function renderBalanceSheet() {
  const container = document.getElementById('tab-bs');
  if (!container) return;
  if (STATE.entries.length === 0) { container.innerHTML = emptyState('لا توجد قيود لعرض قائمة المركز المالي.'); return; }

  const tb = E.buildTrialBalance(STATE.entries, STATE.openingBalances);
  const is = E.buildIncomeStatement(tb);
  const bs = E.buildBalanceSheet(tb, is);

  const renderItems = (items) => items.length === 0
    ? '<tr><td colspan="2" class="text-slate-400 text-center py-2">لا يوجد</td></tr>'
    : items.map(i => `<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;${i.contra ? '(-) ' : ''}${i.name}</td><td class="num-cell">${E.formatNum(i.value, { parens: true })}</td></tr>`).join('');

  container.innerHTML = `
    <div class="mb-3 flex items-center justify-between flex-wrap gap-2">
      <h4 class="font-black text-slate-800 text-xl"><i class="fas fa-building ml-2 text-purple-600"></i>قائمة المركز المالي (الميزانية)</h4>
      ${bs.balanced
        ? `<span class="badge badge-success text-base"><i class="fas fa-check-circle ml-1"></i>متوازنة ✓ (A = L + E)</span>`
        : `<span class="badge badge-danger text-base"><i class="fas fa-exclamation-triangle ml-1"></i>غير متوازنة! فرق: ${E.formatNum(bs.difference)}</span>`}
    </div>
    <div class="info-box text-sm mb-3">
      <strong>قائمة المركز المالي</strong> تعرض الوضع المالي للشركة في لحظة زمنية معينة.
      <strong>المعادلة الأساسية:</strong> الأصول = الخصوم + حقوق الملكية.
      ما تملكه الشركة = ما عليها من التزامات + حق أصحاب الشركة.
    </div>

    <div class="grid md:grid-cols-2 gap-4">
      <!-- الأصول -->
      <div class="border border-blue-200 rounded-xl overflow-hidden">
        <div class="bg-blue-600 text-white font-black text-center py-2">الأصول (Assets)</div>
        <table class="fin-table">
          <tbody>
            <tr class="section-header"><td colspan="2">الأصول المتداولة</td></tr>
            ${renderItems(bs.assetCurrent)}
            <tr class="subtotal"><td>إجمالي الأصول المتداولة</td><td class="num-cell">${E.formatNum(bs.totalCurrentAssets)}</td></tr>
            <tr class="section-header"><td colspan="2">الأصول غير المتداولة</td></tr>
            ${renderItems(bs.assetNonCurrent)}
            <tr class="subtotal"><td>إجمالي الأصول غير المتداولة</td><td class="num-cell">${E.formatNum(bs.totalNonCurrentAssets)}</td></tr>
            <tr class="grand-total"><td>إجمالي الأصول</td><td class="num-cell">${E.formatNum(bs.totalAssets)}</td></tr>
          </tbody>
        </table>
      </div>

      <!-- الخصوم وحقوق الملكية -->
      <div class="border border-red-200 rounded-xl overflow-hidden">
        <div class="bg-red-600 text-white font-black text-center py-2">الخصوم وحقوق الملكية (Liabilities + Equity)</div>
        <table class="fin-table">
          <tbody>
            <tr class="section-header"><td colspan="2">الخصوم المتداولة</td></tr>
            ${renderItems(bs.liabCurrent)}
            <tr class="subtotal"><td>إجمالي الخصوم المتداولة</td><td class="num-cell">${E.formatNum(bs.totalCurrentLiab)}</td></tr>
            <tr class="section-header"><td colspan="2">الخصوم غير المتداولة</td></tr>
            ${renderItems(bs.liabNonCurrent)}
            <tr class="subtotal"><td>إجمالي الخصوم غير المتداولة</td><td class="num-cell">${E.formatNum(bs.totalNonCurrentLiab)}</td></tr>
            <tr class="subtotal"><td><strong>إجمالي الخصوم</strong></td><td class="num-cell"><strong>${E.formatNum(bs.totalLiabilities)}</strong></td></tr>

            <tr class="section-header"><td colspan="2">حقوق الملكية</td></tr>
            ${renderItems(bs.equityItems)}
            <tr><td>&nbsp;&nbsp;&nbsp;&nbsp;صافي ربح/خسارة الفترة</td><td class="num-cell">${E.formatNum(bs.netIncome, { parens: true })}</td></tr>
            <tr class="subtotal"><td>إجمالي حقوق الملكية</td><td class="num-cell">${E.formatNum(bs.totalEquity)}</td></tr>
            <tr class="grand-total"><td>إجمالي الخصوم وحقوق الملكية</td><td class="num-cell">${E.formatNum(bs.totalLiabAndEquity)}</td></tr>
          </tbody>
        </table>
      </div>
    </div>

    <div class="mt-4 p-4 ${bs.balanced ? 'success-box' : 'danger-box'}">
      <strong><i class="fas fa-${bs.balanced ? 'check-circle' : 'exclamation-triangle'}"></i> التحقق من المعادلة المحاسبية:</strong>
      <div class="mt-2 font-mono text-lg">
        إجمالي الأصول (${E.formatNum(bs.totalAssets)})
        ${bs.balanced ? '=' : '≠'}
        الخصوم (${E.formatNum(bs.totalLiabilities)}) + حقوق الملكية (${E.formatNum(bs.totalEquity)})
        = ${E.formatNum(bs.totalLiabAndEquity)}
      </div>
    </div>
  `;
}

// ============ تبويب التغيرات في حقوق الملكية ============
function renderEquityChanges() {
  const container = document.getElementById('tab-eq');
  if (!container) return;
  if (STATE.entries.length === 0) { container.innerHTML = emptyState('لا توجد قيود.'); return; }

  const tb = E.buildTrialBalance(STATE.entries, STATE.openingBalances);
  const is = E.buildIncomeStatement(tb);
  const eq = E.buildEquityChanges(tb, is);

  container.innerHTML = `
    <h4 class="font-black text-slate-800 text-xl mb-3"><i class="fas fa-hand-holding-dollar ml-2 text-amber-600"></i>قائمة التغيرات في حقوق الملكية</h4>
    <div class="info-box text-sm mb-3">
      تُظهر هذه القائمة جميع التغيرات التي طرأت على حقوق الملكية خلال الفترة: إضافات رأس المال، صافي الربح، المسحوبات والتوزيعات.
    </div>
    <div class="overflow-x-auto">
      <table class="fin-table">
        <thead>
          <tr><th>البند</th><th class="num-cell">رأس المال</th><th class="num-cell">الاحتياطي</th><th class="num-cell">الأرباح المحتجزة</th><th class="num-cell">الإجمالي</th></tr>
        </thead>
        <tbody>
          <tr><td>الرصيد الأول</td>
            <td class="num-cell">${E.formatNum(eq.opening.capital)}</td>
            <td class="num-cell">${E.formatNum(eq.opening.legalReserve)}</td>
            <td class="num-cell">${E.formatNum(eq.opening.retainedEarnings)}</td>
            <td class="num-cell font-bold">${E.formatNum(eq.opening.capital + eq.opening.legalReserve + eq.opening.retainedEarnings)}</td>
          </tr>
          <tr><td>(+) صافي ربح الفترة</td>
            <td class="num-cell">-</td><td class="num-cell">-</td>
            <td class="num-cell">${E.formatNum(eq.additions.netIncome, { parens: true })}</td>
            <td class="num-cell font-bold">${E.formatNum(eq.additions.netIncome, { parens: true })}</td>
          </tr>
          ${eq.deductions.drawings ? `<tr><td>(-) المسحوبات الشخصية</td>
            <td class="num-cell">-</td><td class="num-cell">-</td>
            <td class="num-cell">(${E.formatNum(eq.deductions.drawings)})</td>
            <td class="num-cell font-bold">(${E.formatNum(eq.deductions.drawings)})</td>
          </tr>` : ''}
          ${eq.deductions.dividends ? `<tr><td>(-) توزيعات الأرباح</td>
            <td class="num-cell">-</td><td class="num-cell">-</td>
            <td class="num-cell">(${E.formatNum(eq.deductions.dividends)})</td>
            <td class="num-cell font-bold">(${E.formatNum(eq.deductions.dividends)})</td>
          </tr>` : ''}
          <tr class="grand-total">
            <td>الرصيد الختامي</td>
            <td class="num-cell">${E.formatNum(eq.closing.capital)}</td>
            <td class="num-cell">${E.formatNum(eq.closing.legalReserve)}</td>
            <td class="num-cell">${E.formatNum(eq.closing.retainedEarnings)}</td>
            <td class="num-cell">${E.formatNum(eq.closing.total)}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `;
}

// ============ تبويب التدفقات النقدية ============
function renderCashFlow() {
  const container = document.getElementById('tab-cf');
  if (!container) return;
  if (STATE.entries.length === 0) { container.innerHTML = emptyState('لا توجد قيود.'); return; }

  const openingCash = Number(STATE.openingBalances['1101'] || 0) + Number(STATE.openingBalances['1102'] || 0);
  const cf = E.buildCashFlowStatement(STATE.entries, openingCash);

  container.innerHTML = `
    <h4 class="font-black text-slate-800 text-xl mb-3"><i class="fas fa-money-bill-transfer ml-2 text-teal-600"></i>قائمة التدفقات النقدية</h4>
    <div class="info-box text-sm mb-3">
      تُظهر هذه القائمة مصادر واستخدامات النقدية خلال الفترة، مصنّفة إلى ثلاثة أنشطة: تشغيلية، استثمارية، وتمويلية.
    </div>

    <div class="grid md:grid-cols-3 gap-4 mb-4">
      <div class="ratio-card">
        <div class="text-sm text-slate-500"><i class="fas fa-gears ml-1"></i>الأنشطة التشغيلية</div>
        <div class="ratio-value ${cf.operating >= 0 ? 'good' : 'bad'}">${E.formatNum(cf.operating, { parens: true })}</div>
      </div>
      <div class="ratio-card">
        <div class="text-sm text-slate-500"><i class="fas fa-industry ml-1"></i>الأنشطة الاستثمارية</div>
        <div class="ratio-value ${cf.investing >= 0 ? 'good' : 'neutral'}">${E.formatNum(cf.investing, { parens: true })}</div>
      </div>
      <div class="ratio-card">
        <div class="text-sm text-slate-500"><i class="fas fa-hand-holding-usd ml-1"></i>الأنشطة التمويلية</div>
        <div class="ratio-value ${cf.financing >= 0 ? 'good' : 'neutral'}">${E.formatNum(cf.financing, { parens: true })}</div>
      </div>
    </div>

    <div class="overflow-x-auto">
      <table class="fin-table">
        <tbody>
          <tr class="section-header"><td colspan="2">أولاً: التدفقات من الأنشطة التشغيلية</td></tr>
          ${cf.details.operating.map(d => `<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;${d.desc}</td><td class="num-cell">${E.formatNum(d.amount, { parens: true })}</td></tr>`).join('')}
          <tr class="subtotal"><td>صافي التدفق من الأنشطة التشغيلية</td><td class="num-cell">${E.formatNum(cf.operating, { parens: true })}</td></tr>

          <tr class="section-header"><td colspan="2">ثانياً: التدفقات من الأنشطة الاستثمارية</td></tr>
          ${cf.details.investing.length ? cf.details.investing.map(d => `<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;${d.desc}</td><td class="num-cell">${E.formatNum(d.amount, { parens: true })}</td></tr>`).join('') : '<tr><td class="text-slate-400" colspan="2">لا يوجد</td></tr>'}
          <tr class="subtotal"><td>صافي التدفق من الأنشطة الاستثمارية</td><td class="num-cell">${E.formatNum(cf.investing, { parens: true })}</td></tr>

          <tr class="section-header"><td colspan="2">ثالثاً: التدفقات من الأنشطة التمويلية</td></tr>
          ${cf.details.financing.length ? cf.details.financing.map(d => `<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;${d.desc}</td><td class="num-cell">${E.formatNum(d.amount, { parens: true })}</td></tr>`).join('') : '<tr><td class="text-slate-400" colspan="2">لا يوجد</td></tr>'}
          <tr class="subtotal"><td>صافي التدفق من الأنشطة التمويلية</td><td class="num-cell">${E.formatNum(cf.financing, { parens: true })}</td></tr>

          <tr class="grand-total"><td>صافي التغير في النقدية</td><td class="num-cell">${E.formatNum(cf.netChange, { parens: true })}</td></tr>
          <tr><td>رصيد النقدية - أول المدة</td><td class="num-cell">${E.formatNum(cf.openingCash)}</td></tr>
          <tr class="grand-total"><td>رصيد النقدية - آخر المدة</td><td class="num-cell">${E.formatNum(cf.closingCash)}</td></tr>
        </tbody>
      </table>
    </div>
  `;
}

// ============ تبويب التحليل المالي ============
function renderRatios() {
  const container = document.getElementById('tab-ratios');
  if (!container) return;
  if (STATE.entries.length === 0) { container.innerHTML = emptyState('لا توجد قيود لحساب النسب المالية.'); return; }

  const tb = E.buildTrialBalance(STATE.entries, STATE.openingBalances);
  const is = E.buildIncomeStatement(tb);
  const bs = E.buildBalanceSheet(tb, is);
  const r = E.computeRatios(is, bs, tb);

  const card = (cat, key, label, value, unit, formula) => {
    const interp = E.interpretRatio(cat, key, value);
    const displayValue = value === null ? '--' : (unit === '%' ? E.formatNum(value) + '%' : (unit === 'x' ? E.formatNum(value) + '×' : E.formatNum(value)));
    return `
      <div class="ratio-card">
        <div class="flex items-center justify-between mb-2">
          <div class="text-sm font-bold text-slate-600">${label}</div>
          <span class="badge badge-${interp.level === 'good' ? 'success' : interp.level === 'bad' ? 'danger' : interp.level === 'warning' ? 'warning' : 'debit'}">${interp.level === 'good' ? 'ممتاز' : interp.level === 'neutral' ? 'مقبول' : interp.level === 'warning' ? 'تحذير' : interp.level === 'bad' ? 'خطر' : '--'}</span>
        </div>
        <div class="ratio-value ${interp.level}">${displayValue}</div>
        <div class="text-xs text-slate-500 mt-1">${formula}</div>
        <div class="text-xs ${interp.level === 'bad' ? 'text-red-700' : 'text-slate-600'} mt-2">${interp.text}</div>
      </div>
    `;
  };

  container.innerHTML = `
    <h4 class="font-black text-slate-800 text-xl mb-3"><i class="fas fa-chart-line ml-2 text-indigo-600"></i>التحليل المالي الشامل</h4>

    <!-- نسب السيولة -->
    <div class="mb-5">
      <h5 class="font-black text-blue-800 mb-2 border-r-4 border-blue-500 pr-3"><i class="fas fa-tint ml-1"></i>أولاً: نسب السيولة (Liquidity Ratios)</h5>
      <div class="grid md:grid-cols-3 gap-3">
        ${card('liquidity', 'current', 'نسبة التداول', r.liquidity.current, 'x', 'الأصول المتداولة ÷ الخصوم المتداولة')}
        ${card('liquidity', 'quick', 'نسبة السيولة السريعة', r.liquidity.quick, 'x', '(الأصول المتداولة - المخزون) ÷ الخصوم المتداولة')}
        ${card('liquidity', 'cash', 'نسبة النقدية', r.liquidity.cash, 'x', 'النقدية ÷ الخصوم المتداولة')}
      </div>
    </div>

    <!-- نسب الربحية -->
    <div class="mb-5">
      <h5 class="font-black text-green-800 mb-2 border-r-4 border-green-500 pr-3"><i class="fas fa-coins ml-1"></i>ثانياً: نسب الربحية (Profitability Ratios)</h5>
      <div class="grid md:grid-cols-3 gap-3">
        ${card('profitability', 'grossMargin', 'هامش الربح الإجمالي', r.profitability.grossMargin, '%', 'مجمل الربح ÷ صافي المبيعات × 100')}
        ${card('profitability', 'operatingMargin', 'هامش الربح التشغيلي', r.profitability.operatingMargin, '%', 'الربح التشغيلي ÷ صافي المبيعات × 100')}
        ${card('profitability', 'netMargin', 'هامش صافي الربح', r.profitability.netMargin, '%', 'صافي الربح ÷ صافي المبيعات × 100')}
        ${card('profitability', 'roa', 'العائد على الأصول ROA', r.profitability.roa, '%', 'صافي الربح ÷ إجمالي الأصول × 100')}
        ${card('profitability', 'roe', 'العائد على حقوق الملكية ROE', r.profitability.roe, '%', 'صافي الربح ÷ حقوق الملكية × 100')}
      </div>
    </div>

    <!-- نسب النشاط -->
    <div class="mb-5">
      <h5 class="font-black text-purple-800 mb-2 border-r-4 border-purple-500 pr-3"><i class="fas fa-sync ml-1"></i>ثالثاً: نسب النشاط (Activity Ratios)</h5>
      <div class="grid md:grid-cols-3 gap-3">
        ${card('activity', 'inventoryTurnover', 'معدل دوران المخزون', r.activity.inventoryTurnover, 'x', 'تكلفة البضاعة المباعة ÷ المخزون')}
        ${card('activity', 'assetTurnover', 'معدل دوران الأصول', r.activity.assetTurnover, 'x', 'صافي المبيعات ÷ إجمالي الأصول')}
        <div class="ratio-card">
          <div class="text-sm font-bold text-slate-600">متوسط فترة التحصيل</div>
          <div class="ratio-value neutral">${r.activity.daysReceivables ? E.formatNum(r.activity.daysReceivables) + ' يوم' : '--'}</div>
          <div class="text-xs text-slate-500 mt-1">365 ÷ معدل دوران المدينين</div>
        </div>
      </div>
    </div>

    <!-- نسب الرفع المالي -->
    <div class="mb-5">
      <h5 class="font-black text-red-800 mb-2 border-r-4 border-red-500 pr-3"><i class="fas fa-scale-unbalanced ml-1"></i>رابعاً: نسب الرفع المالي / المديونية (Leverage Ratios)</h5>
      <div class="grid md:grid-cols-3 gap-3">
        ${card('leverage', 'debtToAssets', 'نسبة الدين إلى الأصول', r.leverage.debtToAssets, '%', 'إجمالي الخصوم ÷ إجمالي الأصول × 100')}
        ${card('leverage', 'debtToEquity', 'الدين إلى حقوق الملكية', r.leverage.debtToEquity, 'x', 'إجمالي الخصوم ÷ حقوق الملكية')}
        ${card('leverage', 'interestCoverage', 'نسبة تغطية الفوائد', r.leverage.interestCoverage, 'x', 'الربح التشغيلي ÷ مصروف الفوائد')}
      </div>
    </div>

    <!-- رسم بياني -->
    <div class="bg-white border border-slate-200 rounded-xl p-4 mt-4">
      <h5 class="font-black mb-3"><i class="fas fa-chart-pie ml-1"></i>توزيع هيكل التمويل</h5>
      <div class="grid md:grid-cols-2 gap-4">
        <div class="chart-container"><canvas id="chart-funding"></canvas></div>
        <div class="chart-container"><canvas id="chart-income"></canvas></div>
      </div>
    </div>
  `;

  // رسم الـ charts
  setTimeout(() => {
    const ctx1 = document.getElementById('chart-funding');
    if (ctx1) {
      new Chart(ctx1, {
        type: 'doughnut',
        data: {
          labels: ['خصوم متداولة', 'خصوم غير متداولة', 'حقوق الملكية'],
          datasets: [{
            data: [bs.totalCurrentLiab, bs.totalNonCurrentLiab, bs.totalEquity],
            backgroundColor: ['#ef4444', '#f59e0b', '#3b82f6']
          }]
        },
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { font: { family: 'Tajawal' } } }, title: { display: true, text: 'هيكل التمويل', font: { family: 'Tajawal', size: 14 } } } }
      });
    }
    const ctx2 = document.getElementById('chart-income');
    if (ctx2) {
      new Chart(ctx2, {
        type: 'bar',
        data: {
          labels: ['صافي المبيعات', 'تكلفة المبيعات', 'المصروفات التشغيلية', 'صافي الربح'],
          datasets: [{
            data: [is.netSales, is.cogs, is.operatingExp, is.netProfit],
            backgroundColor: ['#10b981', '#f59e0b', '#ef4444', '#3b82f6']
          }]
        },
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false }, title: { display: true, text: 'أرقام قائمة الدخل', font: { family: 'Tajawal', size: 14 } } } }
      });
    }
  }, 100);
}

// ============ حاسبة النسب المالية المستقلة ============
function renderRatiosCalc() {
  const container = document.getElementById('ratios-calc-container');
  if (!container) return;
  container.innerHTML = `
    <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-5">
      <h3 class="text-2xl font-black mb-4"><i class="fas fa-calculator ml-2 text-indigo-600"></i>حاسبة النسب المالية السريعة</h3>
      <p class="text-slate-600 mb-4">أدخل الأرقام الأساسية مباشرة لحساب النسب المالية بدون الحاجة لإدخال قيود.</p>

      <div class="grid md:grid-cols-2 gap-4 mb-4">
        <div class="border rounded-xl p-4">
          <h4 class="font-black text-blue-800 mb-3"><i class="fas fa-building ml-1"></i>بيانات قائمة المركز المالي</h4>
          <div class="space-y-2">
            <label class="block"><span class="text-sm">إجمالي الأصول المتداولة</span><input id="qc-ca" type="number" class="input-field num" value="0" /></label>
            <label class="block"><span class="text-sm">من ذلك: النقدية</span><input id="qc-cash" type="number" class="input-field num" value="0" /></label>
            <label class="block"><span class="text-sm">من ذلك: المخزون</span><input id="qc-inv" type="number" class="input-field num" value="0" /></label>
            <label class="block"><span class="text-sm">الأصول غير المتداولة</span><input id="qc-nca" type="number" class="input-field num" value="0" /></label>
            <label class="block"><span class="text-sm">الخصوم المتداولة</span><input id="qc-cl" type="number" class="input-field num" value="0" /></label>
            <label class="block"><span class="text-sm">الخصوم غير المتداولة</span><input id="qc-ncl" type="number" class="input-field num" value="0" /></label>
            <label class="block"><span class="text-sm">حقوق الملكية</span><input id="qc-eq" type="number" class="input-field num" value="0" /></label>
          </div>
        </div>
        <div class="border rounded-xl p-4">
          <h4 class="font-black text-green-800 mb-3"><i class="fas fa-file-invoice-dollar ml-1"></i>بيانات قائمة الدخل</h4>
          <div class="space-y-2">
            <label class="block"><span class="text-sm">صافي المبيعات</span><input id="qc-sales" type="number" class="input-field num" value="0" /></label>
            <label class="block"><span class="text-sm">تكلفة البضاعة المباعة</span><input id="qc-cogs" type="number" class="input-field num" value="0" /></label>
            <label class="block"><span class="text-sm">مصروفات التشغيل</span><input id="qc-opex" type="number" class="input-field num" value="0" /></label>
            <label class="block"><span class="text-sm">مصروف الفوائد</span><input id="qc-int" type="number" class="input-field num" value="0" /></label>
            <label class="block"><span class="text-sm">مصروف الضريبة</span><input id="qc-tax" type="number" class="input-field num" value="0" /></label>
          </div>
        </div>
      </div>

      <button onclick="runQuickCalc()" class="bg-indigo-600 text-white px-6 py-3 rounded-xl font-black hover:bg-indigo-700 transition text-lg">
        <i class="fas fa-play ml-2"></i>احسب النسب
      </button>

      <div id="qc-results" class="mt-5"></div>
    </div>
  `;
}

function runQuickCalc() {
  const getVal = (id) => Number(document.getElementById(id).value) || 0;
  const ca = getVal('qc-ca'), cash = getVal('qc-cash'), inv = getVal('qc-inv');
  const nca = getVal('qc-nca'), cl = getVal('qc-cl'), ncl = getVal('qc-ncl'), eq = getVal('qc-eq');
  const sales = getVal('qc-sales'), cogs = getVal('qc-cogs'), opex = getVal('qc-opex');
  const interest = getVal('qc-int'), tax = getVal('qc-tax');

  const totalAssets = ca + nca;
  const totalLiab = cl + ncl;
  const grossProfit = sales - cogs;
  const operatingProfit = grossProfit - opex;
  const profitBeforeTax = operatingProfit - interest;
  const netProfit = profitBeforeTax - tax;

  const fakeIS = { grossProfit, netSales: sales, operatingProfit, netProfit, cogs, financeExp: interest };
  const fakeBS = { totalCurrentAssets: ca, totalCurrentLiab: cl, totalAssets, totalEquity: eq, totalLiabilities: totalLiab };
  const fakeTB = { rows: [
    { code: '1101', balanceDr: cash, balanceCr: 0 },
    { code: '1102', balanceDr: 0, balanceCr: 0 },
    { code: '1301', balanceDr: inv, balanceCr: 0 },
    { code: '1201', balanceDr: 0, balanceCr: 0 }
  ]};
  const r = E.computeRatios(fakeIS, fakeBS, fakeTB);

  const drawBar = (label, value, unit, cat, key) => {
    const interp = E.interpretRatio(cat, key, value);
    const display = value === null ? '--' : (unit === '%' ? E.formatNum(value) + '%' : E.formatNum(value) + '×');
    return `<div class="flex justify-between items-center p-3 border-b border-slate-100">
      <span class="font-bold">${label}</span>
      <div class="flex items-center gap-2">
        <span class="ratio-value ${interp.level}" style="font-size:1.1rem">${display}</span>
        <span class="badge badge-${interp.level === 'good' ? 'success' : interp.level === 'bad' ? 'danger' : 'debit'}">${interp.text}</span>
      </div>
    </div>`;
  };

  document.getElementById('qc-results').innerHTML = `
    <div class="bg-white border border-slate-200 rounded-xl overflow-hidden">
      <div class="bg-gradient-to-r from-indigo-600 to-blue-600 text-white p-4 font-black text-lg">
        <i class="fas fa-chart-line ml-2"></i>نتائج التحليل المالي
      </div>
      <div class="p-4 grid md:grid-cols-2 gap-4">
        <div>
          <h5 class="font-black text-blue-800 mb-2"><i class="fas fa-tint ml-1"></i>السيولة</h5>
          ${drawBar('نسبة التداول', r.liquidity.current, 'x', 'liquidity', 'current')}
          ${drawBar('السيولة السريعة', r.liquidity.quick, 'x', 'liquidity', 'quick')}
          ${drawBar('نسبة النقدية', r.liquidity.cash, 'x', 'liquidity', 'cash')}

          <h5 class="font-black text-red-800 mt-4 mb-2"><i class="fas fa-scale-unbalanced ml-1"></i>المديونية</h5>
          ${drawBar('الدين إلى الأصول', r.leverage.debtToAssets, '%', 'leverage', 'debtToAssets')}
          ${drawBar('الدين إلى حقوق الملكية', r.leverage.debtToEquity, 'x', 'leverage', 'debtToEquity')}
          ${drawBar('تغطية الفوائد', r.leverage.interestCoverage, 'x', 'leverage', 'interestCoverage')}
        </div>
        <div>
          <h5 class="font-black text-green-800 mb-2"><i class="fas fa-coins ml-1"></i>الربحية</h5>
          ${drawBar('هامش الربح الإجمالي', r.profitability.grossMargin, '%', 'profitability', 'grossMargin')}
          ${drawBar('هامش الربح التشغيلي', r.profitability.operatingMargin, '%', 'profitability', 'operatingMargin')}
          ${drawBar('هامش صافي الربح', r.profitability.netMargin, '%', 'profitability', 'netMargin')}
          ${drawBar('العائد على الأصول ROA', r.profitability.roa, '%', 'profitability', 'roa')}
          ${drawBar('العائد على حقوق الملكية ROE', r.profitability.roe, '%', 'profitability', 'roe')}

          <h5 class="font-black text-purple-800 mt-4 mb-2"><i class="fas fa-sync ml-1"></i>النشاط</h5>
          ${drawBar('دوران المخزون', r.activity.inventoryTurnover, 'x', 'activity', 'inventoryTurnover')}
          ${drawBar('دوران الأصول', r.activity.assetTurnover, 'x', 'activity', 'assetTurnover')}
        </div>
      </div>

      <div class="bg-slate-50 p-4 border-t border-slate-200">
        <strong>الملخص:</strong>
        صافي الربح = ${E.formatNum(netProfit, { parens: true })}
        | الربح التشغيلي = ${E.formatNum(operatingProfit, { parens: true })}
        | مجمل الربح = ${E.formatNum(grossProfit, { parens: true })}
      </div>
    </div>
  `;
}

// ============ أدوات مساعدة ============
function emptyState(message) {
  return `<div class="text-center py-10 text-slate-500">
    <i class="fas fa-inbox text-5xl mb-3"></i><br>
    <div class="text-lg">${message}</div>
    <div class="text-sm mt-2">انتقل إلى تبويب "اليومية" لإدخال القيود، أو حمّل سيناريو جاهزاً.</div>
  </div>`;
}

// ============ الاختبار السريع ============
function toggleQuiz() {
  const el = document.getElementById('quiz-container');
  if (el) el.classList.toggle('hidden');
}

const QUIZ = [
  { q: 'المعادلة المحاسبية الأساسية هي:',
    options: ['الأصول = الإيرادات + المصروفات', 'الأصول = الخصوم + حقوق الملكية', 'الإيرادات = المصروفات + الربح', 'المدين = المبيعات + الربح'],
    correct: 1,
    explain: 'المعادلة المحاسبية الأساسية: الأصول = الخصوم + حقوق الملكية. هذه المعادلة دائماً متوازنة.' },
  { q: 'عند بيع بضاعة نقداً، ما هو القيد الصحيح؟',
    options: ['من ح/ المبيعات إلى ح/ النقدية', 'من ح/ النقدية إلى ح/ المبيعات', 'من ح/ النقدية إلى ح/ المشتريات', 'من ح/ المشتريات إلى ح/ النقدية'],
    correct: 1,
    explain: 'النقدية أصل (مدين بالزيادة)، والمبيعات إيراد (دائن بالزيادة). القيد: من ح/ النقدية إلى ح/ المبيعات.' },
  { q: 'أي من التالي ليس أصلاً متداولاً؟',
    options: ['المخزون', 'العملاء', 'المباني', 'النقدية بالبنك'],
    correct: 2,
    explain: 'المباني أصل غير متداول (ثابت). الأصول المتداولة تتحول إلى نقدية خلال سنة.' },
  { q: 'الرصيد الطبيعي لحساب الموردين هو:',
    options: ['مدين', 'دائن', 'متذبذب', 'صفر'],
    correct: 1,
    explain: 'الموردون من الخصوم، والخصوم رصيدها الطبيعي دائن.' },
  { q: 'إذا كان صافي المبيعات 100,000 ومجمل الربح 40,000، فإن هامش الربح الإجمالي =',
    options: ['20%', '40%', '60%', '2.5×'],
    correct: 1,
    explain: 'هامش الربح الإجمالي = مجمل الربح ÷ صافي المبيعات × 100 = 40,000 ÷ 100,000 × 100 = 40%.' },
  { q: 'إذا كانت نسبة التداول 3 والخصوم المتداولة 50,000، فإن الأصول المتداولة =',
    options: ['16,666', '150,000', '53,000', '47,000'],
    correct: 1,
    explain: 'نسبة التداول = الأصول المتداولة ÷ الخصوم المتداولة → الأصول = 3 × 50,000 = 150,000.' },
  { q: 'مصروف الإهلاك يظهر في:',
    options: ['قائمة الدخل فقط', 'قائمة المركز المالي فقط', 'كلاهما (المصروف في الدخل والمجمع في المركز)', 'قائمة التدفقات النقدية فقط'],
    correct: 2,
    explain: 'مصروف الإهلاك يظهر في قائمة الدخل، ومجمع الإهلاك يظهر كحساب مقابل للأصل الثابت في المركز المالي.' },
  { q: 'أي من التالي يُصنَّف كتدفق نقدي من النشاط التمويلي؟',
    options: ['شراء آلات', 'دفع مرتبات', 'الحصول على قرض طويل الأجل', 'تحصيل من العملاء'],
    correct: 2,
    explain: 'القروض، إصدار الأسهم، وتوزيعات الأرباح = أنشطة تمويلية. شراء الأصول الثابتة = استثماري. العمليات اليومية = تشغيلي.' },
  { q: 'ROE (العائد على حقوق الملكية) =',
    options: ['صافي الربح ÷ إجمالي الأصول', 'صافي الربح ÷ حقوق الملكية', 'مجمل الربح ÷ حقوق الملكية', 'المبيعات ÷ حقوق الملكية'],
    correct: 1,
    explain: 'ROE = صافي الربح ÷ حقوق الملكية × 100. يقيس العائد الذي يحققه المساهمون على استثماراتهم.' },
  { q: 'عند قبض مبلغ من عميل سبق بيعه بالأجل:',
    options: ['إيراد جديد في قائمة الدخل', 'لا يؤثر على قائمة الدخل (تحصيل لعميل سابق)', 'يُسجل كمصروف', 'يزيد رأس المال'],
    correct: 1,
    explain: 'الإيراد تم الاعتراف به عند البيع (مبدأ الاستحقاق). التحصيل مجرد تحويل من حساب العملاء إلى حساب النقدية - بدون تأثير على قائمة الدخل.' }
];

function renderQuiz() {
  const container = document.getElementById('quiz-content');
  if (!container) return;
  container.innerHTML = QUIZ.map((q, idx) => `
    <div class="bg-white border border-slate-200 rounded-xl p-4 mb-3">
      <div class="font-bold text-slate-800 mb-3"><span class="text-blue-600">س${idx + 1}:</span> ${q.q}</div>
      <div>
        ${q.options.map((opt, optIdx) => `
          <button class="quiz-option" data-q="${idx}" data-opt="${optIdx}" onclick="answerQuiz(${idx}, ${optIdx})">
            ${['أ', 'ب', 'ج', 'د'][optIdx]}) ${opt}
          </button>
        `).join('')}
      </div>
      <div id="quiz-feedback-${idx}" class="mt-2 hidden"></div>
    </div>
  `).join('');
}

function answerQuiz(qIdx, optIdx) {
  const q = QUIZ[qIdx];
  const options = document.querySelectorAll(`.quiz-option[data-q="${qIdx}"]`);
  options.forEach((btn, i) => {
    btn.disabled = true;
    if (i === q.correct) btn.classList.add('correct');
    else if (i === optIdx) btn.classList.add('wrong');
  });
  const fb = document.getElementById(`quiz-feedback-${qIdx}`);
  fb.classList.remove('hidden');
  fb.className = `mt-2 p-3 rounded-lg ${optIdx === q.correct ? 'bg-green-50 border-r-4 border-green-500' : 'bg-red-50 border-r-4 border-red-500'}`;
  fb.innerHTML = `<strong>${optIdx === q.correct ? '✓ إجابة صحيحة!' : '✗ إجابة خاطئة.'}</strong> ${q.explain}`;
}

// ============ البدء ============
window.addEventListener('DOMContentLoaded', () => {
  const initialHash = location.hash.slice(1) || 'home';
  showSection(initialHash);
  if (document.getElementById('quiz-content')) renderQuiz();
});

// كشف دوال للوصول من HTML
window.showSection = showSection;
window.loadScenario = loadScenario;
window.clearAll = clearAll;
window.addLineRow = addLineRow;
window.saveNewEntry = saveNewEntry;
window.deleteEntry = deleteEntry;
window.runQuickCalc = runQuickCalc;
window.toggleQuiz = toggleQuiz;
window.answerQuiz = answerQuiz;
