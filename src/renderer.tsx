import { jsxRenderer } from 'hono/jsx-renderer'

export const renderer = jsxRenderer(({ children }) => {
  return (
    <html lang="ar" dir="rtl">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />

        {/* SEO Meta Tags */}
        <meta name="description" content="منصة تعليمية احترافية لتعلم إعداد القوائم المالية والتحليل المالي بالتطبيق العملي. تعلم المحاسبة من الصفر حتى الاحتراف مع أمثلة تفاعلية واختبارات ذاتية." />
        <meta name="keywords" content="محاسبة, قوائم مالية, تحليل مالي, تعليم المحاسبة, قيود يومية, ميزان مراجعة, قائمة دخل, قائمة مركز مالي, نسب مالية, IFRS" />
        <meta name="author" content="المحاسب المحترف" />
        <meta name="robots" content="index, follow" />

        {/* Open Graph / Facebook */}
        <meta property="og:type" content="website" />
        <meta property="og:url" content="https://accounting-pro.pages.dev" />
        <meta property="og:title" content="المحاسب المحترف - تعلم القوائم المالية والتحليل المالي" />
        <meta property="og:description" content="منصة تعليمية احترافية لتعلم إعداد القوائم المالية والتحليل المالي بالتطبيق العملي" />
        <meta property="og:image" content="https://accounting-pro.pages.dev/static/og-image.png" />
        <meta property="og:locale" content="ar_AR" />

        {/* Twitter */}
        <meta property="twitter:card" content="summary_large_image" />
        <meta property="twitter:url" content="https://accounting-pro.pages.dev" />
        <meta property="twitter:title" content="المحاسب المحترف - تعلم القوائم المالية والتحليل المالي" />
        <meta property="twitter:description" content="منصة تعليمية احترافية لتعلم إعداد القوائم المالية والتحليل المالي بالتطبيق العملي" />
        <meta property="twitter:image" content="https://accounting-pro.pages.dev/static/og-image.png" />

        {/* Theme Color */}
        <meta name="theme-color" content="#0f172a" />
        <meta name="msapplication-TileColor" content="#0f172a" />

        {/* Favicon */}
        <link rel="icon" type="image/svg+xml" href="/static/favicon.svg" />
        <link rel="apple-touch-icon" href="/static/apple-touch-icon.png" />

        <title>المحاسب المحترف - تعلم القوائم المالية والتحليل المالي</title>

        {/* Preconnect for performance */}
        <link rel="preconnect" href="https://cdn.tailwindcss.com" />
        <link rel="preconnect" href="https://cdn.jsdelivr.net" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />

        {/* Tailwind CSS */}
        <script src="https://cdn.tailwindcss.com"></script>

        {/* Font Awesome */}
        <link href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.4.0/css/all.min.css" rel="stylesheet" />

        {/* Google Fonts */}
        <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;500;600;700;800;900&family=Tajawal:wght@200;300;400;500;700;800;900&display=swap" rel="stylesheet" />

        {/* Chart.js */}
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        {/* Custom Styles */}
        <link href="/static/style.css" rel="stylesheet" />

        {/* Structured Data JSON-LD */}
        <script type="application/ld+json">
          {JSON.stringify({
            "@context": "https://schema.org",
            "@type": "WebApplication",
            "name": "المحاسب المحترف",
            "alternateName": "Accounting Pro",
            "applicationCategory": "EducationApplication",
            "operatingSystem": "Any",
            "offers": {
              "@type": "Offer",
              "price": "0",
              "priceCurrency": "USD"
            },
            "description": "منصة تعليمية احترافية لتعلم إعداد القوائم المالية والتحليل المالي بالتطبيق العملي",
            "url": "https://accounting-pro.pages.dev",
            "author": {
              "@type": "Organization",
              "name": "المحاسب المحترف"
            }
          })}
        </script>
      </head>
      <body class="bg-slate-50 text-slate-800 font-sans antialiased">
        {children}
      </body>
    </html>
  )
})
