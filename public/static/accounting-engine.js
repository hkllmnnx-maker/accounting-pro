/* =========================================================================
   محرك المحاسبة - Accounting Engine
   يطبق مبادئ المحاسبة وفق المعايير الدولية (IFRS / IAS 1)
   المعادلة الأساسية: الأصول = الخصوم + حقوق الملكية
   ========================================================================= */

// ---- دليل الحسابات القياسي ----
// طبيعة الحساب: debit (مدين - الأصول والمصروفات) أو credit (دائن - الخصوم والإيرادات وحقوق الملكية)
// تصنيف القائمة: BS_A=أصل، BS_L=التزام، BS_E=حقوق ملكية، IS_R=إيراد، IS_X=مصروف
// تصنيف فرعي في قائمة المركز المالي: CA=متداول، NCA=غير متداول، CL=متداول، NCL=غير متداول

const CHART_OF_ACCOUNTS = {
  // ==== الأصول ====
  "1101": { name: "النقدية بالصندوق", nature: "debit", statement: "BS_A", sub: "CA" },
  "1102": { name: "النقدية بالبنك", nature: "debit", statement: "BS_A", sub: "CA" },
  "1201": { name: "العملاء (المدينون التجاريون)", nature: "debit", statement: "BS_A", sub: "CA" },
  "1202": { name: "أوراق القبض", nature: "debit", statement: "BS_A", sub: "CA" },
  "1203": { name: "مخصص الديون المشكوك في تحصيلها", nature: "credit", statement: "BS_A", sub: "CA", contra: true },
  "1301": { name: "المخزون", nature: "debit", statement: "BS_A", sub: "CA" },
  "1401": { name: "مصروفات مدفوعة مقدماً", nature: "debit", statement: "BS_A", sub: "CA" },
  "1402": { name: "إيرادات مستحقة", nature: "debit", statement: "BS_A", sub: "CA" },
  "1501": { name: "الأراضي", nature: "debit", statement: "BS_A", sub: "NCA" },
  "1502": { name: "المباني", nature: "debit", statement: "BS_A", sub: "NCA" },
  "1503": { name: "مجمع إهلاك المباني", nature: "credit", statement: "BS_A", sub: "NCA", contra: true },
  "1504": { name: "الآلات والمعدات", nature: "debit", statement: "BS_A", sub: "NCA" },
  "1505": { name: "مجمع إهلاك الآلات والمعدات", nature: "credit", statement: "BS_A", sub: "NCA", contra: true },
  "1506": { name: "السيارات", nature: "debit", statement: "BS_A", sub: "NCA" },
  "1507": { name: "مجمع إهلاك السيارات", nature: "credit", statement: "BS_A", sub: "NCA", contra: true },
  "1508": { name: "الأثاث", nature: "debit", statement: "BS_A", sub: "NCA" },
  "1509": { name: "مجمع إهلاك الأثاث", nature: "credit", statement: "BS_A", sub: "NCA", contra: true },
  "1601": { name: "شهرة المحل", nature: "debit", statement: "BS_A", sub: "NCA" },
  "1602": { name: "براءات الاختراع", nature: "debit", statement: "BS_A", sub: "NCA" },

  // ==== الخصوم (الالتزامات) ====
  "2101": { name: "الموردون (الدائنون التجاريون)", nature: "credit", statement: "BS_L", sub: "CL" },
  "2102": { name: "أوراق الدفع", nature: "credit", statement: "BS_L", sub: "CL" },
  "2103": { name: "مصروفات مستحقة", nature: "credit", statement: "BS_L", sub: "CL" },
  "2104": { name: "إيرادات مقبوضة مقدماً", nature: "credit", statement: "BS_L", sub: "CL" },
  "2105": { name: "ضرائب مستحقة", nature: "credit", statement: "BS_L", sub: "CL" },
  "2106": { name: "قروض قصيرة الأجل", nature: "credit", statement: "BS_L", sub: "CL" },
  "2201": { name: "قروض طويلة الأجل", nature: "credit", statement: "BS_L", sub: "NCL" },
  "2202": { name: "سندات مستحقة الدفع", nature: "credit", statement: "BS_L", sub: "NCL" },

  // ==== حقوق الملكية ====
  "3101": { name: "رأس المال", nature: "credit", statement: "BS_E", sub: "EQ" },
  "3102": { name: "الاحتياطي القانوني", nature: "credit", statement: "BS_E", sub: "EQ" },
  "3103": { name: "الأرباح المحتجزة", nature: "credit", statement: "BS_E", sub: "EQ" },
  "3104": { name: "المسحوبات الشخصية", nature: "debit", statement: "BS_E", sub: "EQ", contra: true },
  "3105": { name: "توزيعات الأرباح المعلنة", nature: "debit", statement: "BS_E", sub: "EQ", contra: true },

  // ==== الإيرادات ====
  "4101": { name: "إيرادات المبيعات", nature: "credit", statement: "IS_R", sub: "REV" },
  "4102": { name: "مردودات ومسموحات المبيعات", nature: "debit", statement: "IS_R", sub: "REV", contra: true },
  "4103": { name: "خصم المبيعات المسموح به", nature: "debit", statement: "IS_R", sub: "REV", contra: true },
  "4201": { name: "إيرادات الخدمات", nature: "credit", statement: "IS_R", sub: "REV" },
  "4301": { name: "إيرادات أخرى", nature: "credit", statement: "IS_R", sub: "OTH_INC" },
  "4302": { name: "أرباح بيع أصول ثابتة", nature: "credit", statement: "IS_R", sub: "OTH_INC" },
  "4303": { name: "إيرادات فوائد بنكية", nature: "credit", statement: "IS_R", sub: "OTH_INC" },

  // ==== المصروفات ====
  // تكلفة البضاعة المباعة
  "5101": { name: "تكلفة البضاعة المباعة", nature: "debit", statement: "IS_X", sub: "COGS" },
  "5102": { name: "مشتريات", nature: "debit", statement: "IS_X", sub: "COGS" },
  "5103": { name: "مردودات ومسموحات المشتريات", nature: "credit", statement: "IS_X", sub: "COGS", contra: true },
  "5104": { name: "خصم المشتريات المكتسب", nature: "credit", statement: "IS_X", sub: "COGS", contra: true },
  "5105": { name: "مصروفات نقل المشتريات", nature: "debit", statement: "IS_X", sub: "COGS" },

  // مصروفات بيعية
  "5201": { name: "مرتبات موظفي المبيعات", nature: "debit", statement: "IS_X", sub: "SELL" },
  "5202": { name: "مصروفات إعلان ودعاية", nature: "debit", statement: "IS_X", sub: "SELL" },
  "5203": { name: "عمولات مندوبي البيع", nature: "debit", statement: "IS_X", sub: "SELL" },
  "5204": { name: "مصروفات نقل المبيعات", nature: "debit", statement: "IS_X", sub: "SELL" },

  // مصروفات إدارية وعمومية
  "5301": { name: "الرواتب والأجور الإدارية", nature: "debit", statement: "IS_X", sub: "ADMIN" },
  "5302": { name: "الإيجارات", nature: "debit", statement: "IS_X", sub: "ADMIN" },
  "5303": { name: "الكهرباء والمياه", nature: "debit", statement: "IS_X", sub: "ADMIN" },
  "5304": { name: "الاتصالات والإنترنت", nature: "debit", statement: "IS_X", sub: "ADMIN" },
  "5305": { name: "القرطاسية والمطبوعات", nature: "debit", statement: "IS_X", sub: "ADMIN" },
  "5306": { name: "مصروف الإهلاك", nature: "debit", statement: "IS_X", sub: "ADMIN" },
  "5307": { name: "مصروف الديون المعدومة", nature: "debit", statement: "IS_X", sub: "ADMIN" },
  "5308": { name: "الصيانة", nature: "debit", statement: "IS_X", sub: "ADMIN" },
  "5309": { name: "التأمين", nature: "debit", statement: "IS_X", sub: "ADMIN" },

  // مصروفات تمويلية
  "5401": { name: "فوائد القروض", nature: "debit", statement: "IS_X", sub: "FIN" },
  "5402": { name: "مصروفات بنكية", nature: "debit", statement: "IS_X", sub: "FIN" },

  // مصروف الضريبة
  "5501": { name: "مصروف ضريبة الدخل", nature: "debit", statement: "IS_X", sub: "TAX" },

  // خسائر أخرى
  "5601": { name: "خسائر بيع أصول ثابتة", nature: "debit", statement: "IS_X", sub: "OTH_EXP" }
};

// ---- أدوات مساعدة ----
function round2(n) {
  // تقريب مصرفي دقيق لتفادي أخطاء الفاصلة العائمة
  return Math.round((Number(n) + Number.EPSILON) * 100) / 100;
}

function formatNum(n, opts = {}) {
  if (n === null || n === undefined || isNaN(n)) return "0.00";
  const v = round2(n);
  const abs = Math.abs(v).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  if (opts.parens && v < 0) return `(${abs})`;
  return (v < 0 ? '-' : '') + abs;
}

function getAccount(code) {
  return CHART_OF_ACCOUNTS[code] || null;
}

// ---- محرك القيود (Journal Entries) ----
/**
 * قيد = { id, date, description, lines: [{ accountCode, debit, credit }] }
 * شروط قبول القيد:
 *  1. كل سطر يحتوي إما على مدين فقط أو دائن فقط (ليس كلاهما).
 *  2. مجموع المدين = مجموع الدائن (ضمن حد 0.01).
 *  3. كل كود حساب موجود في دليل الحسابات.
 *  4. جميع المبالغ > 0.
 */
function validateJournalEntry(entry) {
  const errors = [];
  if (!entry.lines || entry.lines.length < 2) {
    errors.push("يجب أن يحتوي القيد على سطرين على الأقل (مدين ودائن).");
    return { valid: false, errors };
  }
  let totalDr = 0, totalCr = 0;
  entry.lines.forEach((line, idx) => {
    const acc = getAccount(line.accountCode);
    if (!acc) errors.push(`السطر ${idx + 1}: الحساب "${line.accountCode}" غير موجود في دليل الحسابات.`);
    const dr = Number(line.debit) || 0;
    const cr = Number(line.credit) || 0;
    if (dr < 0 || cr < 0) errors.push(`السطر ${idx + 1}: لا يمكن إدخال مبالغ سالبة.`);
    if (dr > 0 && cr > 0) errors.push(`السطر ${idx + 1}: لا يمكن أن يكون السطر مديناً ودائناً في نفس الوقت.`);
    if (dr === 0 && cr === 0) errors.push(`السطر ${idx + 1}: يجب إدخال مبلغ في المدين أو الدائن.`);
    totalDr += dr;
    totalCr += cr;
  });
  if (Math.abs(round2(totalDr) - round2(totalCr)) > 0.01) {
    errors.push(`القيد غير متوازن: مجموع المدين ${formatNum(totalDr)} ≠ مجموع الدائن ${formatNum(totalCr)}.`);
  }
  return { valid: errors.length === 0, errors, totalDr: round2(totalDr), totalCr: round2(totalCr) };
}

// ---- بناء ميزان المراجعة (Trial Balance) ----
/**
 * ميزان المراجعة: يجمع حركات كل حساب ويحسب رصيده النهائي.
 * حساب طبيعته مدينة: الرصيد = مجموع المدين - مجموع الدائن (موجب يعني مدين).
 * حساب طبيعته دائنة: الرصيد = مجموع الدائن - مجموع المدين (موجب يعني دائن).
 */
function buildTrialBalance(entries, openingBalances = {}) {
  const accMap = {}; // code -> {debitMovement, creditMovement, openingDr, openingCr}

  // إضافة الأرصدة الافتتاحية
  Object.keys(openingBalances).forEach(code => {
    const acc = getAccount(code);
    if (!acc) return;
    const bal = Number(openingBalances[code]) || 0;
    if (!accMap[code]) accMap[code] = { debitMovement: 0, creditMovement: 0, openingDr: 0, openingCr: 0 };
    if (acc.nature === 'debit') accMap[code].openingDr += bal; // الرصيد المعطى هو الرصيد الطبيعي
    else accMap[code].openingCr += bal;
  });

  // إضافة حركات القيود
  entries.forEach(entry => {
    entry.lines.forEach(line => {
      if (!accMap[line.accountCode]) accMap[line.accountCode] = { debitMovement: 0, creditMovement: 0, openingDr: 0, openingCr: 0 };
      accMap[line.accountCode].debitMovement += Number(line.debit) || 0;
      accMap[line.accountCode].creditMovement += Number(line.credit) || 0;
    });
  });

  // حساب الرصيد النهائي
  const rows = [];
  let totalDr = 0, totalCr = 0;
  Object.keys(accMap).sort().forEach(code => {
    const acc = getAccount(code);
    const m = accMap[code];
    const totalDebit = round2(m.openingDr + m.debitMovement);
    const totalCredit = round2(m.openingCr + m.creditMovement);
    const netBalance = round2(totalDebit - totalCredit); // موجب = مدين، سالب = دائن
    let balDr = 0, balCr = 0;
    if (netBalance >= 0.005) balDr = netBalance;
    else if (netBalance <= -0.005) balCr = -netBalance;
    if (balDr === 0 && balCr === 0) return; // تجاهل الأرصدة الصفرية
    rows.push({
      code, name: acc.name, nature: acc.nature,
      statement: acc.statement, sub: acc.sub, contra: acc.contra || false,
      debitMovement: round2(m.debitMovement),
      creditMovement: round2(m.creditMovement),
      balanceDr: round2(balDr), balanceCr: round2(balCr)
    });
    totalDr += balDr;
    totalCr += balCr;
  });

  return {
    rows,
    totalDebit: round2(totalDr),
    totalCredit: round2(totalCr),
    balanced: Math.abs(round2(totalDr) - round2(totalCr)) < 0.01
  };
}

// ---- قائمة الدخل (Income Statement) ----
/**
 * الهيكل وفق IAS 1 (حسب الوظيفة - by function):
 *   المبيعات (صافي)
 *   - تكلفة البضاعة المباعة
 *   = مجمل الربح
 *   + إيرادات تشغيلية أخرى
 *   - مصروفات بيعية
 *   - مصروفات إدارية
 *   = الربح التشغيلي
 *   + إيرادات أخرى (فوائد، أرباح رأسمالية)
 *   - مصروفات تمويلية
 *   = الربح قبل الضريبة
 *   - مصروف الضريبة
 *   = صافي الربح
 */
function buildIncomeStatement(trialBalance) {
  const getBal = (code) => {
    const r = trialBalance.rows.find(x => x.code === code);
    if (!r) return 0;
    // قيمة الحساب في قائمة الدخل = الرصيد الطبيعي (إيراد يظهر موجباً، مصروف يظهر موجباً كخصم)
    const acc = getAccount(code);
    if (acc.contra) {
      // حساب مقابل: يُخصم من مجموعته
      return round2(acc.nature === 'debit' ? r.balanceDr : r.balanceCr);
    }
    return round2(acc.nature === 'debit' ? r.balanceDr : r.balanceCr);
  };

  const sumBySub = (sub, statement) => {
    let total = 0;
    trialBalance.rows.forEach(r => {
      if (r.statement !== statement || r.sub !== sub) return;
      const acc = getAccount(r.code);
      const val = acc.nature === 'debit' ? r.balanceDr : r.balanceCr;
      total += acc.contra ? -val : val;
    });
    return round2(total);
  };

  // الإيرادات: 4101 المبيعات - 4102 مردودات - 4103 خصم = صافي المبيعات
  const grossSales = getBal("4101") + getBal("4201"); // مبيعات + إيراد خدمات
  const salesReturns = getBal("4102");
  const salesDiscounts = getBal("4103");
  const netSales = round2(grossSales - salesReturns - salesDiscounts);

  // تكلفة البضاعة المباعة: إما مباشر من 5101 أو محسوب من المشتريات
  const cogsDirect = getBal("5101");
  const purchases = getBal("5102");
  const purchRet = getBal("5103");
  const purchDisc = getBal("5104");
  const freightIn = getBal("5105");
  const cogs = round2(cogsDirect + purchases - purchRet - purchDisc + freightIn);

  const grossProfit = round2(netSales - cogs);

  // المصروفات التشغيلية
  const sellingExp = sumBySub("SELL", "IS_X");
  const adminExp = sumBySub("ADMIN", "IS_X");
  const operatingExp = round2(sellingExp + adminExp);

  const operatingProfit = round2(grossProfit - operatingExp);

  // إيرادات ومصاريف أخرى
  const otherIncome = sumBySub("OTH_INC", "IS_R");
  const financeExp = sumBySub("FIN", "IS_X");
  const otherExp = sumBySub("OTH_EXP", "IS_X");

  const profitBeforeTax = round2(operatingProfit + otherIncome - financeExp - otherExp);

  const taxExp = sumBySub("TAX", "IS_X");
  const netProfit = round2(profitBeforeTax - taxExp);

  return {
    grossSales, salesReturns, salesDiscounts, netSales,
    cogs, cogsComponents: { cogsDirect, purchases, purchRet, purchDisc, freightIn },
    grossProfit,
    sellingExp, adminExp, operatingExp,
    operatingProfit,
    otherIncome, financeExp, otherExp,
    profitBeforeTax,
    taxExp,
    netProfit,
    // تفاصيل لعرضها في الواجهة
    details: {
      revenues: trialBalance.rows.filter(r => r.statement === 'IS_R'),
      expenses: trialBalance.rows.filter(r => r.statement === 'IS_X')
    }
  };
}

// ---- قائمة المركز المالي (Balance Sheet) ----
/**
 * وفق IAS 1:
 *   الأصول المتداولة + الأصول غير المتداولة = إجمالي الأصول
 *   الخصوم المتداولة + الخصوم غير المتداولة = إجمالي الخصوم
 *   رأس المال + الاحتياطيات + الأرباح المحتجزة + صافي ربح الفترة - المسحوبات - التوزيعات = حقوق الملكية
 *   إجمالي الأصول يجب أن تساوي (إجمالي الخصوم + حقوق الملكية)
 */
function buildBalanceSheet(trialBalance, incomeStatement) {
  const rows = trialBalance.rows;

  const assetCurrent = [];
  const assetNonCurrent = [];
  const liabCurrent = [];
  const liabNonCurrent = [];
  const equityItems = [];

  rows.forEach(r => {
    const acc = getAccount(r.code);
    // القيمة المعروضة: دائماً بالقيمة الموجبة للرصيد الطبيعي، والحسابات المقابلة تطرح
    const natBal = acc.nature === 'debit' ? r.balanceDr : r.balanceCr;
    const displayVal = acc.contra ? -natBal : natBal;
    const item = { code: r.code, name: r.name, value: round2(displayVal), contra: acc.contra };

    if (r.statement === 'BS_A') {
      if (r.sub === 'CA') assetCurrent.push(item);
      else if (r.sub === 'NCA') assetNonCurrent.push(item);
    } else if (r.statement === 'BS_L') {
      if (r.sub === 'CL') liabCurrent.push(item);
      else if (r.sub === 'NCL') liabNonCurrent.push(item);
    } else if (r.statement === 'BS_E') {
      equityItems.push(item);
    }
  });

  const sumItems = (arr) => round2(arr.reduce((s, x) => s + x.value, 0));

  const totalCurrentAssets = sumItems(assetCurrent);
  const totalNonCurrentAssets = sumItems(assetNonCurrent);
  const totalAssets = round2(totalCurrentAssets + totalNonCurrentAssets);

  const totalCurrentLiab = sumItems(liabCurrent);
  const totalNonCurrentLiab = sumItems(liabNonCurrent);
  const totalLiabilities = round2(totalCurrentLiab + totalNonCurrentLiab);

  // حقوق الملكية: نضيف صافي الربح (من قائمة الدخل) كجزء من الأرباح المحتجزة للفترة
  const openingEquity = sumItems(equityItems);
  const netIncome = incomeStatement ? incomeStatement.netProfit : 0;
  const totalEquity = round2(openingEquity + netIncome);

  const totalLiabAndEquity = round2(totalLiabilities + totalEquity);
  const balanced = Math.abs(totalAssets - totalLiabAndEquity) < 0.01;

  return {
    assetCurrent, assetNonCurrent, liabCurrent, liabNonCurrent, equityItems,
    totalCurrentAssets, totalNonCurrentAssets, totalAssets,
    totalCurrentLiab, totalNonCurrentLiab, totalLiabilities,
    openingEquity, netIncome, totalEquity,
    totalLiabAndEquity, balanced,
    difference: round2(totalAssets - totalLiabAndEquity)
  };
}

// ---- قائمة التغيرات في حقوق الملكية ----
function buildEquityChanges(trialBalance, incomeStatement) {
  const getBal = (code) => {
    const r = trialBalance.rows.find(x => x.code === code);
    if (!r) return 0;
    const acc = getAccount(code);
    return acc.nature === 'debit' ? r.balanceDr : r.balanceCr;
  };
  const capital = getBal("3101");
  const legalReserve = getBal("3102");
  const retainedEarnings = getBal("3103");
  const drawings = getBal("3104");
  const dividends = getBal("3105");
  const netIncome = incomeStatement ? incomeStatement.netProfit : 0;

  return {
    opening: { capital, legalReserve, retainedEarnings },
    additions: { netIncome },
    deductions: { drawings, dividends },
    closing: {
      capital,
      legalReserve,
      retainedEarnings: round2(retainedEarnings + netIncome - drawings - dividends),
      total: round2(capital + legalReserve + retainedEarnings + netIncome - drawings - dividends)
    }
  };
}

// ---- قائمة التدفقات النقدية (طريقة مبسطة - الطريقة المباشرة المبسطة) ----
/**
 * نعرض صافي حركة النقدية من حسابي 1101 و 1102 خلال الفترة
 * ثم نصنفها إلى ثلاث أنشطة:
 * - تشغيلية: من الإيرادات/المصروفات التشغيلية
 * - استثمارية: شراء/بيع أصول ثابتة
 * - تمويلية: قروض، رأس مال، توزيعات أرباح
 */
function buildCashFlowStatement(entries, openingCash = 0) {
  let operating = 0, investing = 0, financing = 0;
  const details = { operating: [], investing: [], financing: [] };

  const cashCodes = ["1101", "1102"];

  entries.forEach(entry => {
    // نحسب صافي حركة النقدية في هذا القيد
    let cashChange = 0;
    entry.lines.forEach(line => {
      if (cashCodes.includes(line.accountCode)) {
        cashChange += (Number(line.debit) || 0) - (Number(line.credit) || 0);
      }
    });
    if (Math.abs(cashChange) < 0.001) return;

    // نصنف حسب الحسابات المقابلة في القيد
    const otherLines = entry.lines.filter(l => !cashCodes.includes(l.accountCode));
    // القاعدة: نأخذ الحساب المقابل الأهم لتصنيف النشاط:
    //   - أصل غير متداول (NCA)       → استثماري
    //   - خصم غير متداول (NCL) أو حقوق ملكية (BS_E) → تمويلي
    //   - غير ذلك (إيراد/مصروف/متداول) → تشغيلي
    let category = 'operating';
    for (const l of otherLines) {
      const acc = getAccount(l.accountCode);
      if (!acc) continue;
      if (acc.statement === 'BS_A' && acc.sub === 'NCA' && !acc.contra) { category = 'investing'; break; }
      if ((acc.statement === 'BS_L' && acc.sub === 'NCL') || acc.statement === 'BS_E') { category = 'financing'; break; }
    }

    const desc = entry.description || '';
    if (category === 'operating') { operating += cashChange; details.operating.push({ desc, amount: round2(cashChange) }); }
    else if (category === 'investing') { investing += cashChange; details.investing.push({ desc, amount: round2(cashChange) }); }
    else { financing += cashChange; details.financing.push({ desc, amount: round2(cashChange) }); }
  });

  const netChange = round2(operating + investing + financing);
  const closingCash = round2(openingCash + netChange);

  return {
    openingCash: round2(openingCash),
    operating: round2(operating),
    investing: round2(investing),
    financing: round2(financing),
    netChange,
    closingCash,
    details
  };
}

// ---- النسب المالية (Financial Ratios) ----
/**
 * النسب المالية الأساسية وفق المعايير الأكاديمية والتطبيقية:
 *
 * 1. نسب السيولة (Liquidity):
 *    - نسبة التداول = الأصول المتداولة / الخصوم المتداولة (المعيار: 2:1)
 *    - نسبة السيولة السريعة = (الأصول المتداولة - المخزون) / الخصوم المتداولة (المعيار: 1:1)
 *    - نسبة النقدية = النقدية / الخصوم المتداولة (المعيار: 0.2:1 أو أعلى)
 *
 * 2. نسب الربحية (Profitability):
 *    - هامش الربح الإجمالي = مجمل الربح / صافي المبيعات × 100
 *    - هامش الربح التشغيلي = الربح التشغيلي / صافي المبيعات × 100
 *    - هامش صافي الربح = صافي الربح / صافي المبيعات × 100
 *    - العائد على الأصول ROA = صافي الربح / إجمالي الأصول × 100
 *    - العائد على حقوق الملكية ROE = صافي الربح / حقوق الملكية × 100
 *
 * 3. نسب النشاط (Activity/Efficiency):
 *    - معدل دوران المخزون = تكلفة البضاعة المباعة / متوسط المخزون
 *    - معدل دوران المدينين = صافي المبيعات الآجلة / متوسط المدينين
 *    - معدل دوران الأصول = صافي المبيعات / إجمالي الأصول
 *
 * 4. نسب المديونية (Leverage):
 *    - نسبة الدين إلى الأصول = إجمالي الخصوم / إجمالي الأصول × 100
 *    - نسبة الدين إلى حقوق الملكية = إجمالي الخصوم / حقوق الملكية
 *    - نسبة تغطية الفوائد = الربح قبل الفوائد والضرائب / مصروف الفوائد
 */
function computeRatios(is, bs, tb) {
  const safeDiv = (a, b) => (b === 0 || b === null || b === undefined) ? null : round2(a / b);
  const pct = (a, b) => safeDiv(a, b) === null ? null : round2((a / b) * 100);

  const getBal = (code) => {
    const r = tb.rows.find(x => x.code === code);
    if (!r) return 0;
    const acc = getAccount(code);
    return acc.nature === 'debit' ? r.balanceDr : r.balanceCr;
  };

  const inventory = getBal("1301");
  const cash = getBal("1101") + getBal("1102");
  const ebit = is.operatingProfit; // الربح قبل الفوائد والضرائب ≈ الربح التشغيلي
  const interest = is.financeExp;

  const ratios = {
    liquidity: {
      current: safeDiv(bs.totalCurrentAssets, bs.totalCurrentLiab),
      quick: safeDiv(bs.totalCurrentAssets - inventory, bs.totalCurrentLiab),
      cash: safeDiv(cash, bs.totalCurrentLiab)
    },
    profitability: {
      grossMargin: pct(is.grossProfit, is.netSales),
      operatingMargin: pct(is.operatingProfit, is.netSales),
      netMargin: pct(is.netProfit, is.netSales),
      roa: pct(is.netProfit, bs.totalAssets),
      roe: pct(is.netProfit, bs.totalEquity)
    },
    activity: {
      inventoryTurnover: safeDiv(is.cogs, inventory),
      receivablesTurnover: safeDiv(is.netSales, getBal("1201")),
      assetTurnover: safeDiv(is.netSales, bs.totalAssets),
      daysInventory: (is.cogs > 0 && inventory > 0) ? round2(365 / (is.cogs / inventory)) : null,
      daysReceivables: (is.netSales > 0 && getBal("1201") > 0) ? round2(365 / (is.netSales / getBal("1201"))) : null
    },
    leverage: {
      debtToAssets: pct(bs.totalLiabilities, bs.totalAssets),
      debtToEquity: safeDiv(bs.totalLiabilities, bs.totalEquity),
      equityRatio: pct(bs.totalEquity, bs.totalAssets),
      interestCoverage: safeDiv(ebit, interest)
    }
  };

  return ratios;
}

// ---- تفسير النسب (Ratio Interpretation) ----
function interpretRatio(category, name, value) {
  if (value === null || value === undefined) return { level: 'na', text: 'لا يمكن الحساب (مقام صفري).' };

  const rules = {
    current: (v) => v >= 2 ? { level: 'good', text: 'ممتاز - الشركة قادرة على سداد التزاماتها قصيرة الأجل بسهولة.' } :
                    v >= 1 ? { level: 'neutral', text: 'مقبول - السيولة كافية لكنها قريبة من الحد الأدنى.' } :
                    { level: 'bad', text: 'خطر - الشركة قد تواجه صعوبات في سداد التزاماتها قصيرة الأجل.' },
    quick: (v) => v >= 1 ? { level: 'good', text: 'ممتاز - سيولة سريعة قوية دون الاعتماد على المخزون.' } :
                  v >= 0.7 ? { level: 'neutral', text: 'مقبول.' } :
                  { level: 'bad', text: 'ضعيف - قد تعتمد الشركة بشكل كبير على تصريف المخزون.' },
    cash: (v) => v >= 0.2 ? { level: 'good', text: 'جيد - توفر نقدي مريح.' } :
                 v >= 0.1 ? { level: 'neutral', text: 'مقبول.' } :
                 { level: 'warning', text: 'نقدية منخفضة.' },
    grossMargin: (v) => v >= 40 ? { level: 'good', text: 'هامش إجمالي قوي.' } :
                        v >= 20 ? { level: 'neutral', text: 'هامش إجمالي متوسط.' } :
                        v >= 0 ? { level: 'warning', text: 'هامش إجمالي منخفض.' } :
                        { level: 'bad', text: 'خسارة إجمالية - التكلفة أعلى من المبيعات!' },
    operatingMargin: (v) => v >= 15 ? { level: 'good', text: 'كفاءة تشغيلية عالية.' } :
                            v >= 5 ? { level: 'neutral', text: 'كفاءة تشغيلية مقبولة.' } :
                            v >= 0 ? { level: 'warning', text: 'كفاءة منخفضة.' } :
                            { level: 'bad', text: 'خسارة تشغيلية.' },
    netMargin: (v) => v >= 10 ? { level: 'good', text: 'ربحية صافية قوية.' } :
                      v >= 3 ? { level: 'neutral', text: 'ربحية مقبولة.' } :
                      v >= 0 ? { level: 'warning', text: 'ربحية ضعيفة.' } :
                      { level: 'bad', text: 'خسارة صافية.' },
    roa: (v) => v >= 10 ? { level: 'good', text: 'استخدام ممتاز للأصول.' } :
                v >= 5 ? { level: 'neutral', text: 'استخدام جيد للأصول.' } :
                v >= 0 ? { level: 'warning', text: 'كفاءة ضعيفة في استخدام الأصول.' } :
                { level: 'bad', text: 'الأصول تحقق خسارة!' },
    roe: (v) => v >= 15 ? { level: 'good', text: 'عائد ممتاز للمساهمين.' } :
                v >= 8 ? { level: 'neutral', text: 'عائد مقبول.' } :
                v >= 0 ? { level: 'warning', text: 'عائد ضعيف.' } :
                { level: 'bad', text: 'خسارة على حقوق الملكية.' },
    debtToAssets: (v) => v <= 40 ? { level: 'good', text: 'هيكل تمويل متحفظ وآمن.' } :
                          v <= 60 ? { level: 'neutral', text: 'مديونية متوسطة.' } :
                          { level: 'bad', text: 'مديونية مرتفعة - مخاطر تمويلية.' },
    debtToEquity: (v) => v <= 1 ? { level: 'good', text: 'هيكل رأسمالي متوازن.' } :
                          v <= 2 ? { level: 'neutral', text: 'مديونية مقبولة.' } :
                          { level: 'bad', text: 'اعتماد مفرط على الدين.' },
    interestCoverage: (v) => v >= 5 ? { level: 'good', text: 'قدرة ممتازة على خدمة الدين.' } :
                              v >= 2 ? { level: 'neutral', text: 'قدرة مقبولة على خدمة الدين.' } :
                              { level: 'bad', text: 'صعوبة في تغطية الفوائد.' },
    inventoryTurnover: (v) => v >= 6 ? { level: 'good', text: 'دوران مخزون سريع.' } :
                               v >= 3 ? { level: 'neutral', text: 'دوران مخزون مقبول.' } :
                               { level: 'warning', text: 'دوران مخزون بطيء - مخزون راكد محتمل.' },
    assetTurnover: (v) => v >= 1.5 ? { level: 'good', text: 'استخدام مكثف للأصول.' } :
                           v >= 0.7 ? { level: 'neutral', text: 'استخدام مقبول للأصول.' } :
                           { level: 'warning', text: 'استخدام ضعيف للأصول.' }
  };

  const fn = rules[name];
  if (!fn) return { level: 'neutral', text: '' };
  return fn(value);
}

// ---- تصدير ----
window.AccountingEngine = {
  CHART_OF_ACCOUNTS,
  getAccount,
  round2,
  formatNum,
  validateJournalEntry,
  buildTrialBalance,
  buildIncomeStatement,
  buildBalanceSheet,
  buildEquityChanges,
  buildCashFlowStatement,
  computeRatios,
  interpretRatio
};
