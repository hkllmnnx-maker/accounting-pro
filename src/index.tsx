import { Hono } from 'hono'
import { renderer } from './renderer'

const app = new Hono()

app.use(renderer)

app.get('/', (c) => {
  return c.render(
    <>
      {/* شريط التنقل المحسّن */}
      <nav class="gradient-primary text-white sticky top-0 z-50 shadow-lg backdrop-blur-md">
        <div class="max-w-7xl mx-auto px-4">
          <div class="flex items-center justify-between h-18">
            {/* Logo */}
            <div class="flex items-center gap-3">
              <div class="w-12 h-12 rounded-xl gradient-gold flex items-center justify-center text-slate-900 shadow-lg animate-pulse-soft">
                <i class="fas fa-chart-pie text-2xl"></i>
              </div>
              <div>
                <div class="font-black text-lg leading-tight">المحاسب المحترف</div>
                <div class="text-xs text-amber-300 font-medium">منصة القوائم المالية والتحليل المالي</div>
              </div>
            </div>

            {/* Desktop Navigation */}
            <div class="hidden md:flex items-center gap-8 font-bold">
              <a href="#home" class="nav-link" data-target="home"><i class="fas fa-home ml-2"></i>الرئيسية</a>
              <a href="#learn" class="nav-link" data-target="learn"><i class="fas fa-graduation-cap ml-2"></i>الدروس</a>
              <a href="#lab" class="nav-link" data-target="lab"><i class="fas fa-flask-vial ml-2"></i>المختبر العملي</a>
              <a href="#ratios-calc" class="nav-link" data-target="ratios-calc"><i class="fas fa-calculator ml-2"></i>حاسبة النسب</a>
              <a href="#quiz" class="nav-link" data-target="quiz"><i class="fas fa-circle-question ml-2"></i>اختبر نفسك</a>
            </div>

            {/* Mobile Menu Button */}
            <button class="md:hidden text-2xl p-2 rounded-lg hover:bg-white/10 transition" onclick="document.getElementById('mobile-menu').classList.toggle('hidden')">
              <i class="fas fa-bars"></i>
            </button>
          </div>

          {/* Mobile Navigation */}
          <div id="mobile-menu" class="md:hidden hidden pb-4 space-y-2 font-bold bg-slate-900/50 backdrop-blur-md rounded-b-xl -mx-4 px-4">
            <a href="#home" class="nav-link block py-3 px-4 rounded-lg hover:bg-white/10 transition flex items-center" data-target="home"><i class="fas fa-home ml-3 w-6 text-center"></i>الرئيسية</a>
            <a href="#learn" class="nav-link block py-3 px-4 rounded-lg hover:bg-white/10 transition flex items-center" data-target="learn"><i class="fas fa-graduation-cap ml-3 w-6 text-center"></i>الدروس</a>
            <a href="#lab" class="nav-link block py-3 px-4 rounded-lg hover:bg-white/10 transition flex items-center" data-target="lab"><i class="fas fa-flask-vial ml-3 w-6 text-center"></i>المختبر العملي</a>
            <a href="#ratios-calc" class="nav-link block py-3 px-4 rounded-lg hover:bg-white/10 transition flex items-center" data-target="ratios-calc"><i class="fas fa-calculator ml-3 w-6 text-center"></i>حاسبة النسب</a>
            <a href="#quiz" class="nav-link block py-3 px-4 rounded-lg hover:bg-white/10 transition flex items-center" data-target="quiz"><i class="fas fa-circle-question ml-3 w-6 text-center"></i>اختبر نفسك</a>
          </div>
        </div>
      </nav>

      {/* القسم الرئيسي - الصفحة الأولى */}
      <section id="home" class="page-section active">
        {/* Hero Section المحسّن */}
        <div class="gradient-primary text-white hero-pattern relative overflow-hidden">
          <div class="max-w-7xl mx-auto px-4 py-20 md:py-32 relative z-10">
            <div class="max-w-3xl">
              {/* Badge */}
              <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-amber-500 text-slate-900 text-sm font-black mb-6 shadow-lg animate-float">
                <i class="fas fa-star text-lg"></i>
                <span>منصة تعليمية احترافية</span>
              </div>

              {/* Main Title */}
              <h1 class="text-5xl md:text-7xl font-black leading-tight mb-6">
                تعلّم <span class="text-amber-400">القوائم المالية</span><br />
                والتحليل المالي <span class="text-teal-300">بالتطبيق العملي</span>
              </h1>

              {/* Description */}
              <p class="text-xl md:text-2xl text-blue-100 leading-relaxed mb-8 max-w-2xl">
                منصة تفاعلية تحوّل قيود اليومية إلى قوائم مالية متكاملة ونسب تحليل مالي تلقائياً،
                بدقة محاسبية وفق المعايير الدولية <span class="font-bold text-amber-400">IFRS</span>.
              </p>

              {/* CTA Buttons */}
              <div class="flex flex-wrap gap-4">
                <a href="#lab" onclick="showSection('lab')" class="btn-primary text-lg">
                  <i class="fas fa-flask-vial text-xl"></i>
                  <span>ابدأ التجربة الآن</span>
                </a>
                <a href="#learn" onclick="showSection('learn')" class="btn-secondary text-lg">
                  <i class="fas fa-book-open text-xl"></i>
                  <span>تعلم الأساسيات</span>
                </a>
              </div>

              {/* Stats */}
              <div class="mt-12 grid grid-cols-3 gap-6 max-w-lg">
                <div class="text-center">
                  <div class="text-3xl font-black text-amber-400">25+</div>
                  <div class="text-sm text-blue-200">اختبار محاسبي</div>
                </div>
                <div class="text-center">
                  <div class="text-3xl font-black text-teal-300">5</div>
                  <div class="text-sm text-blue-200">قوائم مالية</div>
                </div>
                <div class="text-center">
                  <div class="text-3xl font-black text-white">100%</div>
                  <div class="text-sm text-blue-200">مجاني</div>
                </div>
              </div>
            </div>
          </div>

          {/* Decorative Elements */}
          <div class="absolute top-20 left-10 w-32 h-32 bg-amber-500/20 rounded-full blur-3xl"></div>
          <div class="absolute bottom-20 right-10 w-48 h-48 bg-teal-500/20 rounded-full blur-3xl"></div>
        </div>

        {/* المميزات المحسّنة */}
        <div class="max-w-7xl mx-auto px-4 py-16">
          <div class="text-center mb-12">
            <h2 class="text-4xl font-black text-slate-800 mb-4">ماذا ستتعلم في هذه المنصة؟</h2>
            <p class="text-lg text-slate-600 max-w-2xl mx-auto">منصة شاملة تجمع بين التعليم النظري والتطبيق العملي لإتقان المحاسبة المالية</p>
          </div>

          <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {/* Feature Cards */}
            <div class="lesson-card group">
              <div class="icon-wrapper bg-blue-100 text-blue-600 group-hover:bg-blue-600 group-hover:text-white">
                <i class="fas fa-pen"></i>
              </div>
              <h3 class="font-black text-lg mb-2">إعداد قيود اليومية</h3>
              <p class="text-slate-600 text-sm">تعلّم القيد المزدوج وتسجيل العمليات المالية بدقة مع التحقق التلقائي.</p>
            </div>

            <div class="lesson-card group">
              <div class="icon-wrapper bg-green-100 text-green-600 group-hover:bg-green-600 group-hover:text-white">
                <i class="fas fa-scale-balanced"></i>
              </div>
              <h3 class="font-black text-lg mb-2">ميزان المراجعة</h3>
              <p class="text-slate-600 text-sm">بناء ميزان المراجعة آلياً من القيود والتحقق من توازنه في الوقت الفعلي.</p>
            </div>

            <div class="lesson-card group">
              <div class="icon-wrapper bg-emerald-100 text-emerald-600 group-hover:bg-emerald-600 group-hover:text-white">
                <i class="fas fa-file-invoice-dollar"></i>
              </div>
              <h3 class="font-black text-lg mb-2">قائمة الدخل</h3>
              <p class="text-slate-600 text-sm">من المبيعات إلى صافي الربح - بالهيكل الاحترافي وفق معيار IAS 1.</p>
            </div>

            <div class="lesson-card group">
              <div class="icon-wrapper bg-purple-100 text-purple-600 group-hover:bg-purple-600 group-hover:text-white">
                <i class="fas fa-building"></i>
              </div>
              <h3 class="font-black text-lg mb-2">قائمة المركز المالي</h3>
              <p class="text-slate-600 text-sm">الأصول = الخصوم + حقوق الملكية. دائماً متوازنة ودقيقة.</p>
            </div>

            <div class="lesson-card group">
              <div class="icon-wrapper bg-amber-100 text-amber-600 group-hover:bg-amber-600 group-hover:text-white">
                <i class="fas fa-hand-holding-dollar"></i>
              </div>
              <h3 class="font-black text-lg mb-2">حقوق الملكية</h3>
              <p class="text-slate-600 text-sm">تتبع رأس المال والأرباح المحتجزة والتوزيعات بدقة عالية.</p>
            </div>

            <div class="lesson-card group">
              <div class="icon-wrapper bg-teal-100 text-teal-600 group-hover:bg-teal-600 group-hover:text-white">
                <i class="fas fa-money-bill-transfer"></i>
              </div>
              <h3 class="font-black text-lg mb-2">التدفقات النقدية</h3>
              <p class="text-slate-600 text-sm">التشغيلية + الاستثمارية + التمويلية = صافي التغير النقدي.</p>
            </div>

            <div class="lesson-card group">
              <div class="icon-wrapper bg-indigo-100 text-indigo-600 group-hover:bg-indigo-600 group-hover:text-white">
                <i class="fas fa-chart-line"></i>
              </div>
              <h3 class="font-black text-lg mb-2">النسب المالية</h3>
              <p class="text-slate-600 text-sm">السيولة، الربحية، النشاط، والمديونية - مع التفسير التفاعلي.</p>
            </div>

            <div class="lesson-card group">
              <div class="icon-wrapper bg-rose-100 text-rose-600 group-hover:bg-rose-600 group-hover:text-white">
                <i class="fas fa-lightbulb"></i>
              </div>
              <h3 class="font-black text-lg mb-2">تمارين عملية</h3>
              <p class="text-slate-600 text-sm">سيناريوهات جاهزة لشركات مختلفة + اختبارات ذاتية شاملة.</p>
            </div>
          </div>

          {/* كيف تعمل المنصة - محسّن */}
          <div class="mt-20 bg-gradient-to-br from-slate-900 to-blue-900 rounded-3xl p-8 md:p-12 text-white relative overflow-hidden">
            <div class="relative z-10">
              <h2 class="text-4xl font-black text-center mb-12">كيف تعمل المنصة؟</h2>
              <div class="grid md:grid-cols-4 gap-8">
                <div class="text-center group">
                  <div class="w-20 h-20 rounded-full bg-amber-500 text-slate-900 flex items-center justify-center text-2xl font-black mx-auto mb-4 shadow-lg group-hover:scale-110 transition-transform">
                    1
                  </div>
                  <h3 class="font-black text-xl mb-2">أدخل قيود اليومية</h3>
                  <p class="text-sm text-blue-200 leading-relaxed">أو حمّل سيناريو جاهزاً لتتعلم من أمثلة حقيقية.</p>
                </div>
                <div class="text-center group">
                  <div class="w-20 h-20 rounded-full bg-amber-500 text-slate-900 flex items-center justify-center text-2xl font-black mx-auto mb-4 shadow-lg group-hover:scale-110 transition-transform">
                    2
                  </div>
                  <h3 class="font-black text-xl mb-2">المحرك يتحقق</h3>
                  <p class="text-sm text-blue-200 leading-relaxed">من توازن كل قيد (مدين = دائن) قبل قبوله.</p>
                </div>
                <div class="text-center group">
                  <div class="w-20 h-20 rounded-full bg-amber-500 text-slate-900 flex items-center justify-center text-2xl font-black mx-auto mb-4 shadow-lg group-hover:scale-110 transition-transform">
                    3
                  </div>
                  <h3 class="font-black text-xl mb-2">تُبنى القوائم</h3>
                  <p class="text-sm text-blue-200 leading-relaxed">ميزان المراجعة، الدخل، المركز المالي، التدفقات.</p>
                </div>
                <div class="text-center group">
                  <div class="w-20 h-20 rounded-full bg-amber-500 text-slate-900 flex items-center justify-center text-2xl font-black mx-auto mb-4 shadow-lg group-hover:scale-110 transition-transform">
                    4
                  </div>
                  <h3 class="font-black text-xl mb-2">تحليل مالي</h3>
                  <p class="text-sm text-blue-200 leading-relaxed">النسب المالية مع التفسير والحكم على الأداء.</p>
                </div>
              </div>
            </div>

            {/* Decorative elements */}
            <div class="absolute top-0 right-0 w-64 h-64 bg-amber-500/10 rounded-full blur-3xl"></div>
            <div class="absolute bottom-0 left-0 w-64 h-64 bg-blue-500/10 rounded-full blur-3xl"></div>
          </div>

          {/* Call to Action Section */}
          <div class="mt-16 text-center">
            <h2 class="text-3xl font-black text-slate-800 mb-4">جاهز لبدء رحلتك التعليمية؟</h2>
            <p class="text-lg text-slate-600 mb-8 max-w-2xl mx-auto">ابدأ الآن مجاناً واكتشف عالم المحاسبة المالية بطريقة تفاعلية وممتعة</p>
            <div class="flex flex-wrap justify-center gap-4">
              <a href="#lab" onclick="showSection('lab')" class="btn-primary text-lg">
                <i class="fas fa-play"></i>
                <span>ابدأ المختبر العملي</span>
              </a>
              <a href="#learn" onclick="showSection('learn')" class="inline-flex items-center gap-2 px-8 py-4 rounded-xl font-bold text-slate-700 border-2 border-slate-300 hover:border-blue-500 hover:text-blue-600 transition">
                <i class="fas fa-book"></i>
                <span>تصفح الدروس</span>
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* قسم الدروس المحسّن */}
      <section id="learn" class="page-section">
        <div class="max-w-7xl mx-auto px-4 py-10">
          {/* Header */}
          <div class="text-center mb-12">
            <h1 class="text-4xl md:text-5xl font-black text-slate-800 mb-4">
              <i class="fas fa-graduation-cap ml-3 text-blue-600"></i>الدروس التعليمية
            </h1>
            <p class="text-lg text-slate-600 max-w-3xl mx-auto">
              مرجع شامل ومختصر لمفاهيم المحاسبة المالية والتحليل المالي. تعلم من الصفر حتى الاحتراف.
            </p>
          </div>

          {/* الدرس 1: المعادلة المحاسبية */}
          <div class="bg-white rounded-2xl shadow-md border border-slate-200 p-8 mb-8 hover:shadow-lg transition-shadow">
            <h2 class="text-3xl font-black text-slate-800 mb-6 flex items-center">
              <span class="w-12 h-12 rounded-xl bg-amber-100 text-amber-600 flex items-center justify-center text-xl ml-4">١</span>
              المعادلة المحاسبية الأساسية
            </h2>
            <div class="info-box mb-6">
              <p class="font-bold mb-3 text-lg">هي حجر الأساس في المحاسبة:</p>
              <div class="formula text-xl">Assets = Liabilities + Equity</div>
              <div class="formula text-xl" style="background:linear-gradient(135deg, #0f766e 0%, #0f172a 100%);">الأصول = الخصوم + حقوق الملكية</div>
            </div>
            <div class="grid md:grid-cols-3 gap-6">
              <div class="p-6 rounded-xl bg-gradient-to-br from-blue-50 to-blue-100 border border-blue-200 hover:shadow-md transition">
                <div class="w-14 h-14 rounded-xl bg-blue-600 text-white flex items-center justify-center text-2xl mb-4">
                  <i class="fas fa-warehouse"></i>
                </div>
                <h4 class="font-black text-blue-900 text-lg mb-2">الأصول (Assets)</h4>
                <p class="text-slate-700 text-sm leading-relaxed">ما تملكه الشركة من موارد ذات قيمة اقتصادية مستقبلية. مثل: النقدية، العملاء، المخزون، المباني، الآلات، السيارات.</p>
              </div>
              <div class="p-6 rounded-xl bg-gradient-to-br from-red-50 to-red-100 border border-red-200 hover:shadow-md transition">
                <div class="w-14 h-14 rounded-xl bg-red-600 text-white flex items-center justify-center text-2xl mb-4">
                  <i class="fas fa-hand-holding-usd"></i>
                </div>
                <h4 class="font-black text-red-900 text-lg mb-2">الخصوم (Liabilities)</h4>
                <p class="text-slate-700 text-sm leading-relaxed">ما على الشركة من التزامات مالية تجاه الغير. مثل: الموردون، أوراق الدفع، القروض، المصروفات المستحقة.</p>
              </div>
              <div class="p-6 rounded-xl bg-gradient-to-br from-amber-50 to-amber-100 border border-amber-200 hover:shadow-md transition">
                <div class="w-14 h-14 rounded-xl bg-amber-600 text-white flex items-center justify-center text-2xl mb-4">
                  <i class="fas fa-crown"></i>
                </div>
                <h4 class="font-black text-amber-900 text-lg mb-2">حقوق الملكية (Equity)</h4>
                <p class="text-slate-700 text-sm leading-relaxed">حق المالكين في صافي أصول الشركة = الأصول - الخصوم. تشمل: رأس المال، الاحتياطيات، الأرباح المحتجزة.</p>
              </div>
            </div>
          </div>

          {/* الدرس 2: القيد المزدوج */}
          <div class="bg-white rounded-2xl shadow-md border border-slate-200 p-8 mb-8 hover:shadow-lg transition-shadow">
            <h2 class="text-3xl font-black text-slate-800 mb-6 flex items-center">
              <span class="w-12 h-12 rounded-xl bg-blue-100 text-blue-600 flex items-center justify-center text-xl ml-4">٢</span>
              القيد المزدوج
            </h2>
            <p class="text-slate-700 mb-6 text-lg leading-relaxed">
              كل عملية مالية لها طرفان على الأقل: طرف <strong>مدين</strong> (يحصل على شيء أو تزداد قيمته)
              وطرف <strong>دائن</strong> (يعطي شيئاً أو تقل قيمته). يجب أن يتساوى مجموع الطرفين دائماً.
            </p>
            <div class="overflow-x-auto rounded-xl shadow-sm">
              <table class="fin-table">
                <thead>
                  <tr><th>نوع الحساب</th><th>الرصيد الطبيعي</th><th>الزيادة</th><th>النقص</th></tr>
                </thead>
                <tbody>
                  <tr><td class="font-bold"><i class="fas fa-warehouse ml-2 text-blue-500"></i>الأصول</td><td><span class="badge badge-debit">مدين</span></td><td class="text-green-700 font-bold">مدين ↑</td><td class="text-red-700 font-bold">دائن ↓</td></tr>
                  <tr><td class="font-bold"><i class="fas fa-arrow-down ml-2 text-red-500"></i>المصروفات</td><td><span class="badge badge-debit">مدين</span></td><td class="text-green-700 font-bold">مدين ↑</td><td class="text-red-700 font-bold">دائن ↓</td></tr>
                  <tr><td class="font-bold"><i class="fas fa-user-minus ml-2 text-red-500"></i>المسحوبات</td><td><span class="badge badge-debit">مدين</span></td><td class="text-green-700 font-bold">مدين ↑</td><td class="text-red-700 font-bold">دائن ↓</td></tr>
                  <tr><td class="font-bold"><i class="fas fa-hand-holding-usd ml-2 text-red-500"></i>الخصوم</td><td><span class="badge badge-credit">دائن</span></td><td class="text-green-700 font-bold">دائن ↑</td><td class="text-red-700 font-bold">مدين ↓</td></tr>
                  <tr><td class="font-bold"><i class="fas fa-crown ml-2 text-amber-500"></i>حقوق الملكية</td><td><span class="badge badge-credit">دائن</span></td><td class="text-green-700 font-bold">دائن ↑</td><td class="text-red-700 font-bold">مدين ↓</td></tr>
                  <tr><td class="font-bold"><i class="fas fa-arrow-up ml-2 text-green-500"></i>الإيرادات</td><td><span class="badge badge-credit">دائن</span></td><td class="text-green-700 font-bold">دائن ↑</td><td class="text-red-700 font-bold">مدين ↓</td></tr>
                </tbody>
              </table>
            </div>
            <div class="success-box mt-6">
              <h4 class="font-black mb-3"><i class="fas fa-lightbulb ml-2 text-amber-500"></i>مثال تطبيقي:</h4>
              <p class="mb-2">شراء بضاعة بمبلغ 10,000 نقداً:</p>
              <ul class="mt-3 space-y-2">
                <li class="flex items-center gap-2"><span class="badge badge-debit">مدين</span> المخزون (أصل) زاد → 10,000</li>
                <li class="flex items-center gap-2"><span class="badge badge-credit">دائن</span> النقدية (أصل) نقص → 10,000</li>
              </ul>
            </div>
          </div>

          {/* الدرس 3: القوائم المالية الأربع */}
          <div class="bg-white rounded-2xl shadow-md border border-slate-200 p-8 mb-8 hover:shadow-lg transition-shadow">
            <h2 class="text-3xl font-black text-slate-800 mb-6 flex items-center">
              <span class="w-12 h-12 rounded-xl bg-emerald-100 text-emerald-600 flex items-center justify-center text-xl ml-4">٣</span>
              القوائم المالية الأربع
            </h2>
            <p class="text-slate-700 mb-6 text-lg">وفقاً للمعيار الدولي <strong>IAS 1</strong>، يجب على كل منشأة إعداد مجموعة كاملة من القوائم المالية:</p>

            <div class="space-y-6">
              {/* قائمة المركز المالي */}
              <div class="border-r-4 border-blue-500 bg-gradient-to-r from-blue-50 to-white p-6 rounded-l-xl shadow-sm hover:shadow-md transition">
                <h3 class="font-black text-blue-900 text-xl mb-3 flex items-center">
                  <i class="fas fa-building ml-2"></i>(أ) قائمة المركز المالي (Balance Sheet)
                </h3>
                <p class="text-slate-700 mb-3">صورة للوضع المالي في لحظة زمنية محددة (نهاية الفترة).</p>
                <div class="formula">الأصول = الخصوم + حقوق الملكية</div>
                <ul class="text-sm list-disc pr-6 mt-3 space-y-1 text-slate-700">
                  <li><strong>الأصول:</strong> متداولة (نقدية، عملاء، مخزون) + غير متداولة (أراضي، مباني، آلات).</li>
                  <li><strong>الخصوم:</strong> متداولة (موردون، قروض قصيرة) + غير متداولة (قروض طويلة).</li>
                  <li><strong>حقوق الملكية:</strong> رأس المال + الاحتياطيات + الأرباح المحتجزة.</li>
                </ul>
              </div>

              {/* قائمة الدخل */}
              <div class="border-r-4 border-green-500 bg-gradient-to-r from-green-50 to-white p-6 rounded-l-xl shadow-sm hover:shadow-md transition">
                <h3 class="font-black text-green-900 text-xl mb-3 flex items-center">
                  <i class="fas fa-file-invoice-dollar ml-2"></i>(ب) قائمة الدخل (Income Statement)
                </h3>
                <p class="text-slate-700 mb-3">تُظهر نتائج الأعمال (ربح/خسارة) خلال فترة زمنية (شهر/ربع/سنة).</p>
                <div class="formula">الإيرادات - المصروفات = صافي الربح</div>
                <div class="text-sm mt-4 bg-white p-4 rounded-lg">
                  <strong class="text-slate-800">الهيكل المعياري (حسب الوظيفة):</strong>
                  <ol class="list-decimal pr-6 mt-2 space-y-1 text-slate-700">
                    <li>صافي المبيعات = المبيعات - المردودات - الخصومات</li>
                    <li>(-) تكلفة البضاعة المباعة → = <strong>مجمل الربح</strong></li>
                    <li>(-) المصروفات البيعية والإدارية → = <strong>الربح التشغيلي</strong></li>
                    <li>(+/-) إيرادات/مصروفات أخرى → = الربح قبل الضريبة</li>
                    <li>(-) ضريبة الدخل → = <strong>صافي الربح</strong></li>
                  </ol>
                </div>
              </div>

              {/* قائمة التغيرات في حقوق الملكية */}
              <div class="border-r-4 border-amber-500 bg-gradient-to-r from-amber-50 to-white p-6 rounded-l-xl shadow-sm hover:shadow-md transition">
                <h3 class="font-black text-amber-900 text-xl mb-3 flex items-center">
                  <i class="fas fa-hand-holding-dollar ml-2"></i>(ج) قائمة التغيرات في حقوق الملكية
                </h3>
                <p class="text-slate-700 mb-3">تبين الحركة في حقوق المالكين خلال الفترة.</p>
                <div class="formula" style="background:linear-gradient(135deg, #92400e 0%, #b45309 100%);">
                  الرصيد الختامي = الرصيد الأول + صافي الربح + إضافات رأس مال - المسحوبات - التوزيعات
                </div>
              </div>

              {/* قائمة التدفقات النقدية */}
              <div class="border-r-4 border-teal-500 bg-gradient-to-r from-teal-50 to-white p-6 rounded-l-xl shadow-sm hover:shadow-md transition">
                <h3 class="font-black text-teal-900 text-xl mb-3 flex items-center">
                  <i class="fas fa-money-bill-transfer ml-2"></i>(د) قائمة التدفقات النقدية (Cash Flow Statement)
                </h3>
                <p class="text-slate-700 mb-3">تشرح التغير في رصيد النقدية خلال الفترة، مصنفاً حسب النشاط:</p>
                <ul class="text-sm list-disc pr-6 space-y-2 text-slate-700">
                  <li><strong class="text-teal-700">الأنشطة التشغيلية:</strong> التحصيل من العملاء، الدفع للموردين، مصروفات التشغيل.</li>
                  <li><strong class="text-teal-700">الأنشطة الاستثمارية:</strong> شراء/بيع الأصول الثابتة، الاستثمارات.</li>
                  <li><strong class="text-teal-700">الأنشطة التمويلية:</strong> القروض، رأس المال، توزيعات الأرباح.</li>
                </ul>
              </div>
            </div>
          </div>

          {/* الدرس 4: التحليل المالي والنسب */}
          <div class="bg-white rounded-2xl shadow-md border border-slate-200 p-8 mb-8 hover:shadow-lg transition-shadow">
            <h2 class="text-3xl font-black text-slate-800 mb-6 flex items-center">
              <span class="w-12 h-12 rounded-xl bg-indigo-100 text-indigo-600 flex items-center justify-center text-xl ml-4">٤</span>
              النسب المالية الأساسية
            </h2>
            <p class="text-slate-700 mb-6 text-lg">التحليل المالي يُحوّل الأرقام الخام إلى معلومات مفيدة لتقييم أداء الشركة.</p>

            <div class="grid md:grid-cols-2 gap-6">
              <div class="border rounded-xl p-6 border-blue-300 bg-gradient-to-br from-blue-50 to-blue-100/50 hover:shadow-md transition">
                <h3 class="font-black text-blue-900 text-lg mb-4 flex items-center">
                  <i class="fas fa-tint ml-2 text-blue-600"></i>نسب السيولة
                </h3>
                <ul class="text-sm space-y-3 text-slate-700">
                  <li class="flex items-start gap-2"><span class="badge badge-success">مهم</span> <strong>نسبة التداول:</strong> الأصول المتداولة ÷ الخصوم المتداولة (المثالي ≥ 2)</li>
                  <li class="flex items-start gap-2"><span class="badge badge-success">مهم</span> <strong>السيولة السريعة:</strong> (المتداولة - المخزون) ÷ الخصوم المتداولة (≥ 1)</li>
                  <li class="flex items-start gap-2"><span class="badge badge-warning">متوسط</span> <strong>نسبة النقدية:</strong> النقدية ÷ الخصوم المتداولة (≥ 0.2)</li>
                </ul>
              </div>
              <div class="border rounded-xl p-6 border-green-300 bg-gradient-to-br from-green-50 to-green-100/50 hover:shadow-md transition">
                <h3 class="font-black text-green-900 text-lg mb-4 flex items-center">
                  <i class="fas fa-coins ml-2 text-green-600"></i>نسب الربحية
                </h3>
                <ul class="text-sm space-y-3 text-slate-700">
                  <li><strong>هامش الربح الإجمالي:</strong> مجمل الربح ÷ المبيعات × 100</li>
                  <li><strong>هامش الربح التشغيلي:</strong> الربح التشغيلي ÷ المبيعات × 100</li>
                  <li><strong>هامش صافي الربح:</strong> صافي الربح ÷ المبيعات × 100</li>
                  <li><strong>ROA:</strong> صافي الربح ÷ إجمالي الأصول × 100</li>
                  <li><strong>ROE:</strong> صافي الربح ÷ حقوق الملكية × 100</li>
                </ul>
              </div>
              <div class="border rounded-xl p-6 border-purple-300 bg-gradient-to-br from-purple-50 to-purple-100/50 hover:shadow-md transition">
                <h3 class="font-black text-purple-900 text-lg mb-4 flex items-center">
                  <i class="fas fa-sync ml-2 text-purple-600"></i>نسب النشاط
                </h3>
                <ul class="text-sm space-y-3 text-slate-700">
                  <li><strong>دوران المخزون:</strong> تكلفة المبيعات ÷ المخزون</li>
                  <li><strong>دوران الأصول:</strong> المبيعات ÷ إجمالي الأصول</li>
                  <li><strong>فترة التحصيل:</strong> 365 ÷ دوران المدينين</li>
                </ul>
              </div>
              <div class="border rounded-xl p-6 border-red-300 bg-gradient-to-br from-red-50 to-red-100/50 hover:shadow-md transition">
                <h3 class="font-black text-red-900 text-lg mb-4 flex items-center">
                  <i class="fas fa-scale-unbalanced ml-2 text-red-600"></i>نسب الرفع المالي
                </h3>
                <ul class="text-sm space-y-3 text-slate-700">
                  <li><strong>الدين/الأصول:</strong> الخصوم ÷ الأصول × 100</li>
                  <li><strong>الدين/حقوق الملكية:</strong> الخصوم ÷ حقوق الملكية</li>
                  <li><strong>تغطية الفوائد:</strong> الربح التشغيلي ÷ الفوائد</li>
                </ul>
              </div>
            </div>
          </div>

          {/* الدرس 5: مثال عملي */}
          <div class="bg-gradient-to-br from-amber-50 to-orange-50 border-2 border-amber-300 rounded-2xl p-8">
            <h2 class="text-3xl font-black text-amber-900 mb-6 flex items-center">
              <span class="w-12 h-12 rounded-xl bg-amber-500 text-white flex items-center justify-center text-xl ml-4">٥</span>
              مثال عملي متكامل
            </h2>
            <p class="mb-6 text-slate-800 text-lg">إليك مثال متكامل: شركة بدأت نشاطها بـ 100,000 ج.م نقداً، ثم اشترت بضاعة بـ 40,000، وباعت بضاعة بتكلفة 20,000 بمبلغ 35,000 نقداً.</p>

            <div class="space-y-6">
              <div class="bg-white rounded-xl p-6 shadow-sm">
                <h4 class="font-black text-lg mb-4 text-slate-800"><i class="fas fa-pen ml-2 text-blue-600"></i>القيود:</h4>
                <div class="overflow-x-auto">
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
              </div>

              <div class="bg-white rounded-xl p-6 shadow-sm">
                <h4 class="font-black text-lg mb-4 text-slate-800"><i class="fas fa-file-invoice-dollar ml-2 text-green-600"></i>قائمة الدخل:</h4>
                <div class="num font-mono text-left bg-slate-50 p-4 rounded-lg text-slate-800" style="direction:ltr;">
                  <div class="flex justify-between"><span>Sales:</span> <span>35,000</span></div>
                  <div class="flex justify-between"><span>COGS:</span> <span class="text-red-600">(20,000)</span></div>
                  <div class="flex justify-between font-bold text-green-700 border-t border-slate-300 pt-2 mt-2"><span>Gross Profit:</span> <span>15,000</span></div>
                  <div class="flex justify-between font-bold text-blue-700 mt-2"><span>Net Profit:</span> <span>15,000</span></div>
                </div>
              </div>

              <div class="bg-white rounded-xl p-6 shadow-sm">
                <h4 class="font-black text-lg mb-4 text-slate-800"><i class="fas fa-building ml-2 text-purple-600"></i>قائمة المركز المالي:</h4>
                <div class="grid md:grid-cols-2 gap-4 text-sm">
                  <div class="bg-blue-50 p-4 rounded-lg">
                    <strong class="text-blue-900 text-base mb-2 block">الأصول:</strong>
                    <ul class="list-disc pr-6 space-y-1 text-slate-700">
                      <li>البنك: 100,000 - 40,000 + 35,000 = <strong class="text-blue-700">95,000</strong></li>
                      <li>المخزون: 40,000 - 20,000 = <strong class="text-blue-700">20,000</strong></li>
                      <li class="border-t border-blue-200 pt-2 mt-2 font-bold text-blue-900">الإجمالي: 115,000</li>
                    </ul>
                  </div>
                  <div class="bg-amber-50 p-4 rounded-lg">
                    <strong class="text-amber-900 text-base mb-2 block">الخصوم + حقوق الملكية:</strong>
                    <ul class="list-disc pr-6 space-y-1 text-slate-700">
                      <li>رأس المال: <strong>100,000</strong></li>
                      <li>صافي الربح: <strong class="text-green-700">+ 15,000</strong></li>
                      <li class="border-t border-amber-200 pt-2 mt-2 font-bold text-amber-900">الإجمالي: 115,000 ✓</li>
                    </ul>
                  </div>
                </div>
              </div>

              <div class="success-box">
                <strong class="text-lg"><i class="fas fa-check-circle ml-2"></i>التحقق:</strong> إجمالي الأصول (115,000) = إجمالي الخصوم وحقوق الملكية (115,000). المعادلة المحاسبية متوازنة.
              </div>
            </div>

            <div class="mt-8 text-center">
              <a href="#lab" onclick="showSection('lab')" class="btn-primary text-lg inline-flex items-center gap-3">
                <i class="fas fa-play"></i>
                <span>جرّب هذا المثال في المختبر العملي</span>
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

      {/* قسم الاختبار الذاتي المحسّن */}
      <section id="quiz" class="page-section">
        <div class="max-w-4xl mx-auto px-4 py-8">
          {/* Header */}
          <div class="text-center mb-10">
            <h1 class="text-4xl md:text-5xl font-black text-slate-800 mb-4">
              <i class="fas fa-circle-question ml-3 text-rose-600"></i>اختبر نفسك
            </h1>
            <p class="text-lg text-slate-600 max-w-2xl mx-auto">
              عشرة أسئلة محاسبية متنوعة لتقييم فهمك للمحاسبة والتحليل المالي. حاول الحصول على الدرجة الكاملة!
            </p>
          </div>
          <div id="quiz-content"></div>
        </div>
      </section>

      {/* Footer المحسّن */}
      <footer class="gradient-primary text-white mt-16 relative overflow-hidden">
        <div class="max-w-7xl mx-auto px-4 py-12 relative z-10">
          <div class="grid md:grid-cols-3 gap-8 mb-8">
            {/* Brand */}
            <div>
              <div class="flex items-center gap-3 mb-4">
                <div class="w-12 h-12 rounded-xl gradient-gold flex items-center justify-center text-slate-900 shadow-lg">
                  <i class="fas fa-chart-pie text-2xl"></i>
                </div>
                <span class="font-black text-xl">المحاسب المحترف</span>
              </div>
              <p class="text-sm text-blue-200 leading-relaxed">
                منصة تعليمية مجانية لتعلم المحاسبة المالية والتحليل المالي بالتطبيق العملي، وفق المعايير الدولية IFRS.
              </p>
            </div>

            {/* Quick Links */}
            <div>
              <h4 class="font-black mb-4 text-lg">روابط سريعة</h4>
              <ul class="space-y-2 text-sm">
                <li><a href="#home" onclick="showSection('home')" class="hover:text-amber-400 transition flex items-center gap-2"><i class="fas fa-home w-4 text-center"></i>الرئيسية</a></li>
                <li><a href="#learn" onclick="showSection('learn')" class="hover:text-amber-400 transition flex items-center gap-2"><i class="fas fa-graduation-cap w-4 text-center"></i>الدروس</a></li>
                <li><a href="#lab" onclick="showSection('lab')" class="hover:text-amber-400 transition flex items-center gap-2"><i class="fas fa-flask-vial w-4 text-center"></i>المختبر العملي</a></li>
                <li><a href="#ratios-calc" onclick="showSection('ratios-calc')" class="hover:text-amber-400 transition flex items-center gap-2"><i class="fas fa-calculator w-4 text-center"></i>حاسبة النسب</a></li>
              </ul>
            </div>

            {/* Warning */}
            <div>
              <h4 class="font-black mb-4 text-lg">تنبيه مهم</h4>
              <p class="text-sm text-blue-200 leading-relaxed">
                المنصة للأغراض التعليمية فقط. للأعمال الرسمية، يُرجى الرجوع لمحاسب قانوني مختص والالتزام بالقوانين المحلية والمعايير الدولية.
              </p>
            </div>
          </div>

          <div class="border-t border-white/20 pt-6 flex flex-col md:flex-row items-center justify-between gap-4">
            <p class="text-sm text-blue-200">
              © 2026 المحاسب المحترف - جميع الحقوق محفوظة
            </p>
            <p class="text-sm text-blue-200 flex items-center gap-2">
              <i class="fas fa-code"></i>
              مبني بـ Hono + Cloudflare Pages
            </p>
          </div>
        </div>

        {/* Decorative elements */}
        <div class="absolute top-0 left-0 w-48 h-48 bg-amber-500/10 rounded-full blur-3xl"></div>
        <div class="absolute bottom-0 right-0 w-64 h-64 bg-teal-500/10 rounded-full blur-3xl"></div>
      </footer>

      {/* Scripts */}
      <script src="/static/accounting-engine.js"></script>
      <script src="/static/app.js"></script>
      <script src="/static/engine-tests.js"></script>
    </>
  )
})

export default app
