import { Hono } from 'hono'
import { renderer } from './renderer'

const app = new Hono()

app.use(renderer)

app.get('/', (c) => {
  return c.render(
    <>
      {/* شريط التنقل */}
      <nav class="gradient-primary text-white sticky top-0 z-50 shadow-lg">
        <div class="max-w-7xl mx-auto px-4">
          <div class="flex items-center justify-between h-16">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-xl gradient-gold flex items-center justify-center text-slate-900">
                <i class="fas fa-chart-pie text-xl"></i>
              </div>
              <div>
                <div class="font-black text-lg leading-tight">المحاسب المحترف</div>
                <div class="text-xs text-amber-300">منصة القوائم المالية والتحليل المالي</div>
              </div>
            </div>
            <div class="hidden md:flex items-center gap-6 font-bold">
              <a href="#home" class="nav-link" data-target="home"><i class="fas fa-home ml-1"></i>الرئيسية</a>
              <a href="#learn" class="nav-link" data-target="learn"><i class="fas fa-graduation-cap ml-1"></i>الدروس</a>
              <a href="#lab" class="nav-link" data-target="lab"><i class="fas fa-flask-vial ml-1"></i>المختبر العملي</a>
              <a href="#ratios-calc" class="nav-link" data-target="ratios-calc"><i class="fas fa-calculator ml-1"></i>حاسبة النسب</a>
              <a href="#quiz" class="nav-link" data-target="quiz"><i class="fas fa-circle-question ml-1"></i>اختبر نفسك</a>
            </div>
            <button class="md:hidden text-2xl" onclick="document.getElementById('mobile-menu').classList.toggle('hidden')">
              <i class="fas fa-bars"></i>
            </button>
          </div>
          <div id="mobile-menu" class="md:hidden hidden pb-4 space-y-2 font-bold">
            <a href="#home" class="nav-link block py-2" data-target="home">الرئيسية</a>
            <a href="#learn" class="nav-link block py-2" data-target="learn">الدروس</a>
            <a href="#lab" class="nav-link block py-2" data-target="lab">المختبر العملي</a>
            <a href="#ratios-calc" class="nav-link block py-2" data-target="ratios-calc">حاسبة النسب</a>
            <a href="#quiz" class="nav-link block py-2" data-target="quiz">اختبر نفسك</a>
          </div>
        </div>
      </nav>

      {/* القسم الرئيسي - الصفحة الأولى */}
      <section id="home" class="page-section active">
        <div class="gradient-primary text-white hero-pattern">
          <div class="max-w-7xl mx-auto px-4 py-16 md:py-24">
            <div class="max-w-3xl">
              <div class="inline-block px-3 py-1 rounded-full bg-amber-500 text-slate-900 text-sm font-black mb-4">
                <i class="fas fa-star ml-1"></i>منصة تعليمية احترافية
              </div>
              <h1 class="text-4xl md:text-6xl font-black leading-tight mb-4">
                تعلّم <span class="text-amber-400">القوائم المالية</span><br />
                والتحليل المالي <span class="text-teal-300">بالتطبيق العملي</span>
              </h1>
              <p class="text-lg md:text-xl text-blue-100 leading-relaxed mb-6">
                منصة تفاعلية تحوّل قيود اليومية إلى قوائم مالية متكاملة ونسب تحليل مالي تلقائياً،
                بدقة محاسبية وفق المعايير الدولية IFRS.
              </p>
              <div class="flex flex-wrap gap-3">
                <a href="#lab" onclick="showSection('lab')" class="bg-amber-500 hover:bg-amber-600 text-slate-900 px-6 py-3 rounded-xl font-black text-lg transition">
                  <i class="fas fa-flask-vial ml-2"></i>ابدأ التجربة الآن
                </a>
                <a href="#learn" onclick="showSection('learn')" class="bg-white/10 hover:bg-white/20 border border-white/30 text-white px-6 py-3 rounded-xl font-black text-lg transition">
                  <i class="fas fa-book-open ml-2"></i>تعلم الأساسيات
                </a>
              </div>
            </div>
          </div>
        </div>

        {/* المميزات */}
        <div class="max-w-7xl mx-auto px-4 py-12">
          <h2 class="text-3xl font-black text-center mb-10">ماذا ستتعلم في هذه المنصة؟</h2>
          <div class="grid md:grid-cols-3 lg:grid-cols-4 gap-4">
            <div class="lesson-card bg-white rounded-2xl p-5 shadow-sm">
              <div class="w-12 h-12 rounded-xl bg-blue-100 text-blue-600 flex items-center justify-center text-2xl mb-3"><i class="fas fa-pen"></i></div>
              <h3 class="font-black mb-2">إعداد قيود اليومية</h3>
              <p class="text-sm text-slate-600">تعلّم القيد المزدوج وتسجيل العمليات المالية بدقة.</p>
            </div>
            <div class="lesson-card bg-white rounded-2xl p-5 shadow-sm">
              <div class="w-12 h-12 rounded-xl bg-green-100 text-green-600 flex items-center justify-center text-2xl mb-3"><i class="fas fa-scale-balanced"></i></div>
              <h3 class="font-black mb-2">ميزان المراجعة</h3>
              <p class="text-sm text-slate-600">بناء ميزان المراجعة آلياً من القيود والتحقق من توازنه.</p>
            </div>
            <div class="lesson-card bg-white rounded-2xl p-5 shadow-sm">
              <div class="w-12 h-12 rounded-xl bg-emerald-100 text-emerald-600 flex items-center justify-center text-2xl mb-3"><i class="fas fa-file-invoice-dollar"></i></div>
              <h3 class="font-black mb-2">قائمة الدخل</h3>
              <p class="text-sm text-slate-600">من المبيعات إلى صافي الربح - بالهيكل الاحترافي.</p>
            </div>
            <div class="lesson-card bg-white rounded-2xl p-5 shadow-sm">
              <div class="w-12 h-12 rounded-xl bg-purple-100 text-purple-600 flex items-center justify-center text-2xl mb-3"><i class="fas fa-building"></i></div>
              <h3 class="font-black mb-2">قائمة المركز المالي</h3>
              <p class="text-sm text-slate-600">الأصول = الخصوم + حقوق الملكية. متوازنة دائماً.</p>
            </div>
            <div class="lesson-card bg-white rounded-2xl p-5 shadow-sm">
              <div class="w-12 h-12 rounded-xl bg-amber-100 text-amber-600 flex items-center justify-center text-2xl mb-3"><i class="fas fa-hand-holding-dollar"></i></div>
              <h3 class="font-black mb-2">التغيرات في حقوق الملكية</h3>
              <p class="text-sm text-slate-600">تتبع رأس المال والأرباح المحتجزة والتوزيعات.</p>
            </div>
            <div class="lesson-card bg-white rounded-2xl p-5 shadow-sm">
              <div class="w-12 h-12 rounded-xl bg-teal-100 text-teal-600 flex items-center justify-center text-2xl mb-3"><i class="fas fa-money-bill-transfer"></i></div>
              <h3 class="font-black mb-2">قائمة التدفقات النقدية</h3>
              <p class="text-sm text-slate-600">التشغيلية + الاستثمارية + التمويلية = صافي التغير النقدي.</p>
            </div>
            <div class="lesson-card bg-white rounded-2xl p-5 shadow-sm">
              <div class="w-12 h-12 rounded-xl bg-indigo-100 text-indigo-600 flex items-center justify-center text-2xl mb-3"><i class="fas fa-chart-line"></i></div>
              <h3 class="font-black mb-2">النسب المالية</h3>
              <p class="text-sm text-slate-600">السيولة، الربحية، النشاط، والمديونية - مع التفسير.</p>
            </div>
            <div class="lesson-card bg-white rounded-2xl p-5 shadow-sm">
              <div class="w-12 h-12 rounded-xl bg-rose-100 text-rose-600 flex items-center justify-center text-2xl mb-3"><i class="fas fa-lightbulb"></i></div>
              <h3 class="font-black mb-2">تمارين عملية</h3>
              <p class="text-sm text-slate-600">سيناريوهات جاهزة لشركات مختلفة + اختبارات ذاتية.</p>
            </div>
          </div>

          {/* كيف تعمل المنصة */}
          <div class="mt-16 bg-gradient-to-br from-slate-900 to-blue-900 rounded-3xl p-8 text-white">
            <h2 class="text-3xl font-black text-center mb-8">كيف تعمل المنصة؟</h2>
            <div class="grid md:grid-cols-4 gap-4">
              <div class="text-center">
                <div class="w-16 h-16 rounded-full bg-amber-500 text-slate-900 flex items-center justify-center text-2xl font-black mx-auto mb-3">1</div>
                <h3 class="font-black mb-2">أدخل قيود اليومية</h3>
                <p class="text-sm text-blue-200">أو حمّل سيناريو جاهزاً لتتعلم من أمثلة حقيقية.</p>
              </div>
              <div class="text-center">
                <div class="w-16 h-16 rounded-full bg-amber-500 text-slate-900 flex items-center justify-center text-2xl font-black mx-auto mb-3">2</div>
                <h3 class="font-black mb-2">المحرك يتحقق تلقائياً</h3>
                <p class="text-sm text-blue-200">من توازن كل قيد (مدين = دائن) قبل قبوله.</p>
              </div>
              <div class="text-center">
                <div class="w-16 h-16 rounded-full bg-amber-500 text-slate-900 flex items-center justify-center text-2xl font-black mx-auto mb-3">3</div>
                <h3 class="font-black mb-2">تُبنى القوائم آلياً</h3>
                <p class="text-sm text-blue-200">ميزان المراجعة، الدخل، المركز المالي، التدفقات، حقوق الملكية.</p>
              </div>
              <div class="text-center">
                <div class="w-16 h-16 rounded-full bg-amber-500 text-slate-900 flex items-center justify-center text-2xl font-black mx-auto mb-3">4</div>
                <h3 class="font-black mb-2">تحليل مالي احترافي</h3>
                <p class="text-sm text-blue-200">النسب المالية مع التفسير والحكم على الأداء.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* قسم الدروس */}
      <section id="learn" class="page-section">
        <div class="max-w-7xl mx-auto px-4 py-10">
          <h1 class="text-4xl font-black text-slate-800 mb-2"><i class="fas fa-graduation-cap ml-2 text-blue-600"></i>الدروس التعليمية</h1>
          <p class="text-slate-600 mb-8">مرجع شامل ومختصر لمفاهيم المحاسبة المالية والتحليل المالي.</p>

          {/* الدرس 1: المعادلة المحاسبية */}
          <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 mb-6">
            <h2 class="text-2xl font-black text-slate-800 mb-3"><i class="fas fa-equals ml-2 text-amber-600"></i>١. المعادلة المحاسبية الأساسية</h2>
            <div class="info-box">
              <p class="font-bold mb-2">هي حجر الأساس في المحاسبة:</p>
              <div class="formula text-xl">Assets = Liabilities + Equity</div>
              <div class="formula text-xl" style="background:#1e40af;">الأصول = الخصوم + حقوق الملكية</div>
            </div>
            <div class="grid md:grid-cols-3 gap-3 mt-4">
              <div class="p-4 rounded-xl bg-blue-50 border border-blue-200">
                <h4 class="font-black text-blue-800 mb-2">الأصول (Assets)</h4>
                <p class="text-sm">ما تملكه الشركة من موارد ذات قيمة اقتصادية مستقبلية. مثل: النقدية، العملاء، المخزون، المباني، الآلات، السيارات.</p>
              </div>
              <div class="p-4 rounded-xl bg-red-50 border border-red-200">
                <h4 class="font-black text-red-800 mb-2">الخصوم (Liabilities)</h4>
                <p class="text-sm">ما على الشركة من التزامات مالية تجاه الغير. مثل: الموردون، أوراق الدفع، القروض، المصروفات المستحقة.</p>
              </div>
              <div class="p-4 rounded-xl bg-amber-50 border border-amber-200">
                <h4 class="font-black text-amber-800 mb-2">حقوق الملكية (Equity)</h4>
                <p class="text-sm">حق المالكين في صافي أصول الشركة = الأصول - الخصوم. تشمل: رأس المال، الاحتياطيات، الأرباح المحتجزة.</p>
              </div>
            </div>
          </div>

          {/* الدرس 2: القيد المزدوج */}
          <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 mb-6">
            <h2 class="text-2xl font-black text-slate-800 mb-3"><i class="fas fa-balance-scale ml-2 text-blue-600"></i>٢. القيد المزدوج</h2>
            <p class="text-slate-700 mb-3">
              كل عملية مالية لها طرفان على الأقل: طرف <strong>مدين</strong> (يحصل على شيء أو تزداد قيمته)
              وطرف <strong>دائن</strong> (يعطي شيئاً أو تقل قيمته). يجب أن يتساوى مجموع الطرفين دائماً.
            </p>
            <div class="overflow-x-auto">
              <table class="fin-table">
                <thead>
                  <tr><th>نوع الحساب</th><th>الرصيد الطبيعي</th><th>الزيادة</th><th>النقص</th></tr>
                </thead>
                <tbody>
                  <tr><td class="font-bold">الأصول</td><td><span class="badge badge-debit">مدين</span></td><td class="text-green-700 font-bold">مدين ↑</td><td class="text-red-700 font-bold">دائن ↓</td></tr>
                  <tr><td class="font-bold">المصروفات</td><td><span class="badge badge-debit">مدين</span></td><td class="text-green-700 font-bold">مدين ↑</td><td class="text-red-700 font-bold">دائن ↓</td></tr>
                  <tr><td class="font-bold">المسحوبات</td><td><span class="badge badge-debit">مدين</span></td><td class="text-green-700 font-bold">مدين ↑</td><td class="text-red-700 font-bold">دائن ↓</td></tr>
                  <tr><td class="font-bold">الخصوم</td><td><span class="badge badge-credit">دائن</span></td><td class="text-green-700 font-bold">دائن ↑</td><td class="text-red-700 font-bold">مدين ↓</td></tr>
                  <tr><td class="font-bold">حقوق الملكية</td><td><span class="badge badge-credit">دائن</span></td><td class="text-green-700 font-bold">دائن ↑</td><td class="text-red-700 font-bold">مدين ↓</td></tr>
                  <tr><td class="font-bold">الإيرادات</td><td><span class="badge badge-credit">دائن</span></td><td class="text-green-700 font-bold">دائن ↑</td><td class="text-red-700 font-bold">مدين ↓</td></tr>
                </tbody>
              </table>
            </div>
            <div class="success-box mt-4">
              <strong>مثال:</strong> شراء بضاعة بمبلغ 10,000 نقداً:
              <ul class="mt-2 list-disc pr-6">
                <li>المخزون (أصل) زاد → <span class="badge badge-debit">مدين</span> 10,000</li>
                <li>النقدية (أصل) نقص → <span class="badge badge-credit">دائن</span> 10,000</li>
              </ul>
            </div>
          </div>

          {/* الدرس 3: القوائم المالية الأربع */}
          <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 mb-6">
            <h2 class="text-2xl font-black text-slate-800 mb-3"><i class="fas fa-file-lines ml-2 text-emerald-600"></i>٣. القوائم المالية الأربع</h2>
            <p class="text-slate-700 mb-4">وفقاً للمعيار الدولي IAS 1، يجب على كل منشأة إعداد مجموعة كاملة من القوائم المالية تتضمن:</p>

            <div class="space-y-4">
              <div class="border-r-4 border-blue-500 bg-blue-50 p-4 rounded-l-xl">
                <h3 class="font-black text-blue-900 mb-2"><i class="fas fa-building ml-1"></i>(أ) قائمة المركز المالي (Balance Sheet)</h3>
                <p class="text-sm mb-2">صورة للوضع المالي في لحظة زمنية محددة (نهاية الفترة).</p>
                <div class="formula">الأصول = الخصوم + حقوق الملكية</div>
                <ul class="text-sm list-disc pr-6 mt-2">
                  <li><strong>الأصول:</strong> متداولة (نقدية، عملاء، مخزون) + غير متداولة (أراضي، مباني، آلات).</li>
                  <li><strong>الخصوم:</strong> متداولة (موردون، قروض قصيرة) + غير متداولة (قروض طويلة).</li>
                  <li><strong>حقوق الملكية:</strong> رأس المال + الاحتياطيات + الأرباح المحتجزة.</li>
                </ul>
              </div>

              <div class="border-r-4 border-green-500 bg-green-50 p-4 rounded-l-xl">
                <h3 class="font-black text-green-900 mb-2"><i class="fas fa-file-invoice-dollar ml-1"></i>(ب) قائمة الدخل (Income Statement)</h3>
                <p class="text-sm mb-2">تُظهر نتائج الأعمال (ربح/خسارة) خلال فترة زمنية (شهر/ربع/سنة).</p>
                <div class="formula">الإيرادات - المصروفات = صافي الربح</div>
                <div class="text-sm mt-2">
                  <strong>الهيكل المعياري (حسب الوظيفة):</strong>
                  <ol class="list-decimal pr-6 mt-1">
                    <li>صافي المبيعات = المبيعات - المردودات - الخصومات</li>
                    <li>(-) تكلفة البضاعة المباعة → = <strong>مجمل الربح</strong></li>
                    <li>(-) المصروفات البيعية والإدارية → = <strong>الربح التشغيلي</strong></li>
                    <li>(+/-) إيرادات/مصروفات أخرى → = الربح قبل الضريبة</li>
                    <li>(-) ضريبة الدخل → = <strong>صافي الربح</strong></li>
                  </ol>
                </div>
              </div>

              <div class="border-r-4 border-amber-500 bg-amber-50 p-4 rounded-l-xl">
                <h3 class="font-black text-amber-900 mb-2"><i class="fas fa-hand-holding-dollar ml-1"></i>(ج) قائمة التغيرات في حقوق الملكية</h3>
                <p class="text-sm mb-2">تبين الحركة في حقوق المالكين خلال الفترة.</p>
                <div class="formula" style="background:#92400e;">
                  الرصيد الختامي = الرصيد الأول + صافي الربح + إضافات رأس مال - المسحوبات - التوزيعات
                </div>
              </div>

              <div class="border-r-4 border-teal-500 bg-teal-50 p-4 rounded-l-xl">
                <h3 class="font-black text-teal-900 mb-2"><i class="fas fa-money-bill-transfer ml-1"></i>(د) قائمة التدفقات النقدية (Cash Flow Statement)</h3>
                <p class="text-sm mb-2">تشرح التغير في رصيد النقدية خلال الفترة، مصنفاً حسب النشاط:</p>
                <ul class="text-sm list-disc pr-6">
                  <li><strong>الأنشطة التشغيلية:</strong> التحصيل من العملاء، الدفع للموردين، مصروفات التشغيل.</li>
                  <li><strong>الأنشطة الاستثمارية:</strong> شراء/بيع الأصول الثابتة، الاستثمارات.</li>
                  <li><strong>الأنشطة التمويلية:</strong> القروض، رأس المال، توزيعات الأرباح.</li>
                </ul>
              </div>
            </div>
          </div>

          {/* الدرس 4: التحليل المالي والنسب */}
          <div class="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 mb-6">
            <h2 class="text-2xl font-black text-slate-800 mb-3"><i class="fas fa-chart-line ml-2 text-indigo-600"></i>٤. النسب المالية الأساسية</h2>
            <p class="text-slate-700 mb-4">التحليل المالي يُحوّل الأرقام الخام إلى معلومات مفيدة لتقييم أداء الشركة.</p>

            <div class="grid md:grid-cols-2 gap-4">
              <div class="border rounded-xl p-4 border-blue-300 bg-blue-50/50">
                <h3 class="font-black text-blue-900 mb-2"><i class="fas fa-tint ml-1"></i>نسب السيولة</h3>
                <ul class="text-sm space-y-2">
                  <li><strong>نسبة التداول:</strong> الأصول المتداولة ÷ الخصوم المتداولة (المثالي ≥ 2)</li>
                  <li><strong>السيولة السريعة:</strong> (المتداولة - المخزون) ÷ الخصوم المتداولة (≥ 1)</li>
                  <li><strong>نسبة النقدية:</strong> النقدية ÷ الخصوم المتداولة (≥ 0.2)</li>
                </ul>
              </div>
              <div class="border rounded-xl p-4 border-green-300 bg-green-50/50">
                <h3 class="font-black text-green-900 mb-2"><i class="fas fa-coins ml-1"></i>نسب الربحية</h3>
                <ul class="text-sm space-y-2">
                  <li><strong>هامش الربح الإجمالي:</strong> مجمل الربح ÷ المبيعات × 100</li>
                  <li><strong>هامش الربح التشغيلي:</strong> الربح التشغيلي ÷ المبيعات × 100</li>
                  <li><strong>هامش صافي الربح:</strong> صافي الربح ÷ المبيعات × 100</li>
                  <li><strong>ROA:</strong> صافي الربح ÷ إجمالي الأصول × 100</li>
                  <li><strong>ROE:</strong> صافي الربح ÷ حقوق الملكية × 100</li>
                </ul>
              </div>
              <div class="border rounded-xl p-4 border-purple-300 bg-purple-50/50">
                <h3 class="font-black text-purple-900 mb-2"><i class="fas fa-sync ml-1"></i>نسب النشاط</h3>
                <ul class="text-sm space-y-2">
                  <li><strong>دوران المخزون:</strong> تكلفة المبيعات ÷ المخزون</li>
                  <li><strong>دوران الأصول:</strong> المبيعات ÷ إجمالي الأصول</li>
                  <li><strong>فترة التحصيل:</strong> 365 ÷ دوران المدينين</li>
                </ul>
              </div>
              <div class="border rounded-xl p-4 border-red-300 bg-red-50/50">
                <h3 class="font-black text-red-900 mb-2"><i class="fas fa-scale-unbalanced ml-1"></i>نسب الرفع المالي</h3>
                <ul class="text-sm space-y-2">
                  <li><strong>الدين/الأصول:</strong> الخصوم ÷ الأصول × 100</li>
                  <li><strong>الدين/حقوق الملكية:</strong> الخصوم ÷ حقوق الملكية</li>
                  <li><strong>تغطية الفوائد:</strong> الربح التشغيلي ÷ الفوائد</li>
                </ul>
              </div>
            </div>
          </div>

          {/* الدرس 5: مثال عملي */}
          <div class="bg-gradient-to-br from-amber-50 to-orange-50 border-2 border-amber-300 rounded-2xl p-6">
            <h2 class="text-2xl font-black text-amber-900 mb-3"><i class="fas fa-lightbulb ml-2"></i>٥. مثال عملي متكامل</h2>
            <p class="mb-3">إليك مثال متكامل: شركة بدأت نشاطها بـ 100,000 ج.م نقداً، ثم اشترت بضاعة بـ 40,000، وباعت بضاعة بتكلفة 20,000 بمبلغ 35,000 نقداً.</p>

            <div class="bg-white rounded-xl p-4 mb-3">
              <h4 class="font-black mb-2">القيود:</h4>
              <table class="fin-table text-sm">
                <thead>
                  <tr><th>البيان</th><th>مدين</th><th>دائن</th><th>المبلغ</th></tr>
                </thead>
                <tbody>
                  <tr><td>تأسيس الشركة</td><td>البنك</td><td>رأس المال</td><td class="num-cell">100,000</td></tr>
                  <tr><td>شراء بضاعة</td><td>المخزون</td><td>البنك</td><td class="num-cell">40,000</td></tr>
                  <tr><td>بيع نقدي</td><td>البنك</td><td>المبيعات</td><td class="num-cell">35,000</td></tr>
                  <tr><td>تكلفة المبيعات</td><td>تكلفة البضاعة المباعة</td><td>المخزون</td><td class="num-cell">20,000</td></tr>
                </tbody>
              </table>
            </div>

            <div class="bg-white rounded-xl p-4 mb-3">
              <h4 class="font-black mb-2">قائمة الدخل:</h4>
              <div class="num font-mono text-left bg-slate-50 p-3 rounded-lg" style="direction:ltr;">
                <div>Sales: 35,000</div>
                <div>COGS: (20,000)</div>
                <div><strong>Gross Profit: 15,000</strong></div>
                <div><strong>Net Profit: 15,000</strong> (بلا مصروفات أخرى)</div>
              </div>
            </div>

            <div class="bg-white rounded-xl p-4">
              <h4 class="font-black mb-2">قائمة المركز المالي:</h4>
              <div class="grid md:grid-cols-2 gap-3 text-sm">
                <div>
                  <strong>الأصول:</strong>
                  <ul class="list-disc pr-6">
                    <li>البنك: 100,000 - 40,000 + 35,000 = 95,000</li>
                    <li>المخزون: 40,000 - 20,000 = 20,000</li>
                    <li><strong>الإجمالي: 115,000</strong></li>
                  </ul>
                </div>
                <div>
                  <strong>الخصوم + حقوق الملكية:</strong>
                  <ul class="list-disc pr-6">
                    <li>رأس المال: 100,000</li>
                    <li>صافي الربح: 15,000</li>
                    <li><strong>الإجمالي: 115,000 ✓</strong></li>
                  </ul>
                </div>
              </div>
              <div class="success-box mt-3">
                <strong>✓ التحقق:</strong> إجمالي الأصول (115,000) = إجمالي الخصوم وحقوق الملكية (115,000). المعادلة المحاسبية متوازنة.
              </div>
            </div>

            <div class="mt-4 text-center">
              <a href="#lab" onclick="showSection('lab')" class="inline-block bg-amber-600 hover:bg-amber-700 text-white px-6 py-3 rounded-xl font-black">
                <i class="fas fa-play ml-2"></i>جرّب هذا المثال في المختبر العملي
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* قسم المختبر العملي */}
      <section id="lab" class="page-section">
        <div class="max-w-7xl mx-auto px-4 py-8">
          <div id="lab-container"></div>
        </div>
      </section>

      {/* قسم حاسبة النسب */}
      <section id="ratios-calc" class="page-section">
        <div class="max-w-5xl mx-auto px-4 py-8">
          <div id="ratios-calc-container"></div>
        </div>
      </section>

      {/* قسم الاختبار الذاتي */}
      <section id="quiz" class="page-section">
        <div class="max-w-4xl mx-auto px-4 py-8">
          <h1 class="text-4xl font-black text-slate-800 mb-2"><i class="fas fa-circle-question ml-2 text-rose-600"></i>اختبر نفسك</h1>
          <p class="text-slate-600 mb-6">عشرة أسئلة لتتأكد من فهمك للمحاسبة والتحليل المالي.</p>
          <div id="quiz-content"></div>
        </div>
      </section>

      {/* Footer */}
      <footer class="gradient-primary text-white mt-10">
        <div class="max-w-7xl mx-auto px-4 py-8">
          <div class="grid md:grid-cols-3 gap-6 mb-6">
            <div>
              <div class="flex items-center gap-2 mb-3">
                <i class="fas fa-chart-pie text-amber-400 text-2xl"></i>
                <span class="font-black text-lg">المحاسب المحترف</span>
              </div>
              <p class="text-sm text-blue-200">منصة تعليمية مجانية لتعلم المحاسبة المالية والتحليل المالي بالتطبيق العملي، وفق المعايير الدولية.</p>
            </div>
            <div>
              <h4 class="font-black mb-3">روابط سريعة</h4>
              <ul class="space-y-1 text-sm">
                <li><a href="#home" class="hover:text-amber-400">الرئيسية</a></li>
                <li><a href="#learn" class="hover:text-amber-400">الدروس</a></li>
                <li><a href="#lab" class="hover:text-amber-400">المختبر العملي</a></li>
                <li><a href="#ratios-calc" class="hover:text-amber-400">حاسبة النسب</a></li>
              </ul>
            </div>
            <div>
              <h4 class="font-black mb-3">تنبيه مهم</h4>
              <p class="text-sm text-blue-200">المنصة للأغراض التعليمية. للأعمال الرسمية، يُرجى الرجوع لمحاسب قانوني مختص والالتزام بالقوانين المحلية والمعايير الدولية.</p>
            </div>
          </div>
          <div class="border-t border-white/20 pt-4 text-center text-sm text-blue-200">
            © 2026 المحاسب المحترف - جميع الحقوق محفوظة | مبني بـ Hono + Cloudflare Pages
          </div>
        </div>
      </footer>

      {/* Scripts */}
      <script src="/static/accounting-engine.js"></script>
      <script src="/static/app.js"></script>
      <script src="/static/engine-tests.js"></script>
    </>
  )
})

export default app
