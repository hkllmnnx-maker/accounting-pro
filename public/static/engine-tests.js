/* اختبارات دقة محرك المحاسبة
   تُشغَّل في الكونسول للتأكد من صحة الحسابات قبل استخدامها في الإنتاج */
(function () {
  const E = window.AccountingEngine;
  const results = [];
  const assert = (name, cond, info) => {
    results.push({ name, pass: !!cond, info: info || '' });
  };

  // ============== اختبار 1: التحقق من القيد المتوازن ==============
  {
    const entry = {
      id: 1, date: '2024-01-01', description: 'رأس المال',
      lines: [
        { accountCode: '1102', debit: 100000, credit: 0 },
        { accountCode: '3101', debit: 0, credit: 100000 }
      ]
    };
    const v = E.validateJournalEntry(entry);
    assert('قيد متوازن (رأس المال)', v.valid && v.totalDr === 100000 && v.totalCr === 100000);
  }

  // ============== اختبار 2: قيد غير متوازن ==============
  {
    const entry = {
      lines: [
        { accountCode: '1102', debit: 100, credit: 0 },
        { accountCode: '3101', debit: 0, credit: 90 }
      ]
    };
    const v = E.validateJournalEntry(entry);
    assert('رفض قيد غير متوازن', !v.valid);
  }

  // ============== اختبار 3: ميزان المراجعة ==============
  {
    const entries = [
      { id:1, date:'2024-01-01', description:'رأس المال', lines:[{accountCode:'1102',debit:50000,credit:0},{accountCode:'3101',debit:0,credit:50000}] },
      { id:2, date:'2024-01-05', description:'شراء بضاعة نقداً', lines:[{accountCode:'5102',debit:20000,credit:0},{accountCode:'1102',debit:0,credit:20000}] },
      { id:3, date:'2024-01-10', description:'مبيعات نقدية', lines:[{accountCode:'1102',debit:35000,credit:0},{accountCode:'4101',debit:0,credit:35000}] }
    ];
    const tb = E.buildTrialBalance(entries);
    assert('ميزان المراجعة متوازن', tb.balanced, `Dr=${tb.totalDebit} Cr=${tb.totalCredit}`);
    const bank = tb.rows.find(r => r.code === '1102');
    assert('رصيد البنك = 65,000 مدين', bank && bank.balanceDr === 65000 && bank.balanceCr === 0);
    const sales = tb.rows.find(r => r.code === '4101');
    assert('رصيد المبيعات = 35,000 دائن', sales && sales.balanceCr === 35000);
  }

  // ============== اختبار 4: قائمة الدخل الكاملة ==============
  {
    const entries = [
      // رأس مال
      { lines: [{accountCode:'1102',debit:200000,credit:0},{accountCode:'3101',debit:0,credit:200000}] },
      // مشتريات
      { lines: [{accountCode:'5102',debit:80000,credit:0},{accountCode:'1102',debit:0,credit:80000}] },
      // مبيعات نقدية
      { lines: [{accountCode:'1102',debit:150000,credit:0},{accountCode:'4101',debit:0,credit:150000}] },
      // مصروف رواتب
      { lines: [{accountCode:'5301',debit:15000,credit:0},{accountCode:'1102',debit:0,credit:15000}] },
      // مصروف إيجار
      { lines: [{accountCode:'5302',debit:10000,credit:0},{accountCode:'1102',debit:0,credit:10000}] },
      // مخزون آخر المدة (تسوية): نخصم من المشتريات 80,000، نفترض cogs مباشر بدلاً من ذلك
      // لتبسيط الاختبار، استخدم قيد تكلفة مباعة بدل المشتريات:
    ];
    // إعادة هيكلة: استخدم تكلفة البضاعة المباعة مباشرة
    const entries2 = [
      { lines: [{accountCode:'1102',debit:200000,credit:0},{accountCode:'3101',debit:0,credit:200000}] },
      { lines: [{accountCode:'1301',debit:80000,credit:0},{accountCode:'1102',debit:0,credit:80000}] }, // شراء مخزون
      { lines: [{accountCode:'1102',debit:150000,credit:0},{accountCode:'4101',debit:0,credit:150000}] }, // مبيعات
      { lines: [{accountCode:'5101',debit:60000,credit:0},{accountCode:'1301',debit:0,credit:60000}] }, // تكلفة مباعة
      { lines: [{accountCode:'5301',debit:15000,credit:0},{accountCode:'1102',debit:0,credit:15000}] },
      { lines: [{accountCode:'5302',debit:10000,credit:0},{accountCode:'1102',debit:0,credit:10000}] }
    ];
    const tb = E.buildTrialBalance(entries2);
    const is = E.buildIncomeStatement(tb);
    assert('صافي المبيعات = 150,000', is.netSales === 150000, `got ${is.netSales}`);
    assert('تكلفة المبيعات = 60,000', is.cogs === 60000, `got ${is.cogs}`);
    assert('مجمل الربح = 90,000', is.grossProfit === 90000, `got ${is.grossProfit}`);
    assert('المصروفات الإدارية = 25,000', is.adminExp === 25000, `got ${is.adminExp}`);
    assert('الربح التشغيلي = 65,000', is.operatingProfit === 65000, `got ${is.operatingProfit}`);
    assert('صافي الربح = 65,000 (بلا ضريبة)', is.netProfit === 65000, `got ${is.netProfit}`);

    // اختبار المركز المالي
    const bs = E.buildBalanceSheet(tb, is);
    // النقدية: 200,000 - 80,000 + 150,000 - 15,000 - 10,000 = 245,000
    // المخزون: 80,000 - 60,000 = 20,000
    // إجمالي الأصول = 245,000 + 20,000 = 265,000
    assert('إجمالي الأصول = 265,000', bs.totalAssets === 265000, `got ${bs.totalAssets}`);
    // حقوق الملكية: رأس المال 200,000 + صافي الربح 65,000 = 265,000
    assert('إجمالي حقوق الملكية = 265,000', bs.totalEquity === 265000, `got ${bs.totalEquity}`);
    assert('الميزانية متوازنة (A = L + E)', bs.balanced, `diff=${bs.difference}`);
  }

  // ============== اختبار 5: النسب المالية ==============
  {
    const entries = [
      { lines: [{accountCode:'1102',debit:100000,credit:0},{accountCode:'3101',debit:0,credit:100000}] },
      { lines: [{accountCode:'1301',debit:40000,credit:0},{accountCode:'2101',debit:0,credit:40000}] }, // شراء بالأجل
      { lines: [{accountCode:'1201',debit:80000,credit:0},{accountCode:'4101',debit:0,credit:80000}] }, // مبيعات آجلة
      { lines: [{accountCode:'5101',debit:30000,credit:0},{accountCode:'1301',debit:0,credit:30000}] }  // تكلفة
    ];
    const tb = E.buildTrialBalance(entries);
    const is = E.buildIncomeStatement(tb);
    const bs = E.buildBalanceSheet(tb, is);
    const ratios = E.computeRatios(is, bs, tb);
    // الأصول المتداولة: نقدية 100,000 + مخزون 10,000 + عملاء 80,000 = 190,000
    // الخصوم المتداولة: موردين 40,000
    // نسبة التداول = 190,000 / 40,000 = 4.75
    assert('نسبة التداول = 4.75', ratios.liquidity.current === 4.75, `got ${ratios.liquidity.current}`);
    // السريعة = (190,000 - 10,000) / 40,000 = 4.5
    assert('نسبة السيولة السريعة = 4.5', ratios.liquidity.quick === 4.5, `got ${ratios.liquidity.quick}`);
    // مجمل الربح = 80,000 - 30,000 = 50,000 → هامش = 62.5%
    assert('هامش الربح الإجمالي = 62.5%', ratios.profitability.grossMargin === 62.5, `got ${ratios.profitability.grossMargin}`);
  }

  // ============== اختبار 6: دقة حسابية عند وجود كسور ==============
  {
    const entries = [
      { lines: [{accountCode:'1102',debit:333.33,credit:0},{accountCode:'4101',debit:0,credit:333.33}] },
      { lines: [{accountCode:'1102',debit:666.67,credit:0},{accountCode:'4101',debit:0,credit:666.67}] }
    ];
    const tb = E.buildTrialBalance(entries);
    const sales = tb.rows.find(r => r.code === '4101');
    assert('جمع الكسور دقيق = 1,000.00', sales.balanceCr === 1000, `got ${sales.balanceCr}`);
  }

  // ============== اختبار 7: قائمة الدخل مع خصومات ومردودات ==============
  {
    const entries = [
      { lines: [{accountCode:'1102',debit:100000,credit:0},{accountCode:'3101',debit:0,credit:100000}] },
      { lines: [{accountCode:'1102',debit:200000,credit:0},{accountCode:'4101',debit:0,credit:200000}] }, // مبيعات
      { lines: [{accountCode:'4102',debit:10000,credit:0},{accountCode:'1102',debit:0,credit:10000}] },  // مردودات مبيعات
      { lines: [{accountCode:'4103',debit:5000,credit:0},{accountCode:'1102',debit:0,credit:5000}] },   // خصم مسموح به
      { lines: [{accountCode:'5101',debit:100000,credit:0},{accountCode:'1102',debit:0,credit:100000}] } // تكلفة
    ];
    const tb = E.buildTrialBalance(entries);
    const is = E.buildIncomeStatement(tb);
    // صافي المبيعات = 200,000 - 10,000 - 5,000 = 185,000
    assert('صافي المبيعات بعد الخصومات = 185,000', is.netSales === 185000, `got ${is.netSales}`);
    assert('مجمل الربح = 85,000', is.grossProfit === 85000, `got ${is.grossProfit}`);
  }

  // ============== اختبار 8: توازن المعادلة المحاسبية مع خصوم متنوعة ==============
  {
    const entries = [
      { lines: [{accountCode:'1102',debit:500000,credit:0},{accountCode:'3101',debit:0,credit:500000}] }, // رأس مال
      { lines: [{accountCode:'1102',debit:200000,credit:0},{accountCode:'2201',debit:0,credit:200000}] }, // قرض طويل
      { lines: [{accountCode:'1504',debit:300000,credit:0},{accountCode:'1102',debit:0,credit:300000}] }, // شراء آلات
      { lines: [{accountCode:'1301',debit:150000,credit:0},{accountCode:'2101',debit:0,credit:150000}] }  // مخزون بالأجل
    ];
    const tb = E.buildTrialBalance(entries);
    const is = E.buildIncomeStatement(tb);
    const bs = E.buildBalanceSheet(tb, is);
    // الأصول: نقدية 400,000 + آلات 300,000 + مخزون 150,000 = 850,000
    // الخصوم: قرض 200,000 + موردين 150,000 = 350,000
    // حقوق الملكية: 500,000
    // المجموع: 350,000 + 500,000 = 850,000 ✓
    assert('الميزانية متوازنة (مع خصوم متنوعة)', bs.balanced && bs.totalAssets === 850000, `assets=${bs.totalAssets} L+E=${bs.totalLiabAndEquity}`);
  }

  // ============== اختبار 9: قائمة التدفقات النقدية ==============
  {
    const entries = [
      { description:'رأس المال', lines: [{accountCode:'1102',debit:100000,credit:0},{accountCode:'3101',debit:0,credit:100000}] }, // تمويلي
      { description:'شراء معدات', lines: [{accountCode:'1504',debit:40000,credit:0},{accountCode:'1102',debit:0,credit:40000}] }, // استثماري
      { description:'مبيعات نقدية', lines: [{accountCode:'1102',debit:30000,credit:0},{accountCode:'4101',debit:0,credit:30000}] }, // تشغيلي
      { description:'دفع رواتب', lines: [{accountCode:'5301',debit:10000,credit:0},{accountCode:'1102',debit:0,credit:10000}] } // تشغيلي
    ];
    const cf = E.buildCashFlowStatement(entries, 0);
    assert('تدفق تمويلي = 100,000', cf.financing === 100000, `got ${cf.financing}`);
    assert('تدفق استثماري = -40,000', cf.investing === -40000, `got ${cf.investing}`);
    assert('تدفق تشغيلي = 20,000', cf.operating === 20000, `got ${cf.operating}`);
    assert('صافي التغير = 80,000', cf.netChange === 80000, `got ${cf.netChange}`);
  }

  // ============== طباعة النتائج ==============
  const passed = results.filter(r => r.pass).length;
  const failed = results.filter(r => !r.pass).length;
  console.log(`%c === اختبارات محرك المحاسبة ===`, 'font-weight:bold; font-size:14px; color:#1e40af;');
  results.forEach(r => {
    if (r.pass) console.log(`%c✓ ${r.name}`, 'color:#16a34a;');
    else console.log(`%c✗ ${r.name} — ${r.info}`, 'color:#dc2626; font-weight:bold;');
  });
  console.log(`%c النتيجة: ${passed} نجح / ${failed} فشل من ${results.length}`, `font-weight:bold; color:${failed === 0 ? '#16a34a' : '#dc2626'};`);
  window.__engineTestsResults = { passed, failed, total: results.length };
})();
