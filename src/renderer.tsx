import { jsxRenderer } from 'hono/jsx-renderer'

export const renderer = jsxRenderer(({ children }) => {
  return (
    <html lang="ar" dir="rtl">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="description" content="منصة تعليمية احترافية لتعلم إعداد القوائم المالية والتحليل المالي بالتطبيق العملي" />
        <title>المحاسب المحترف - تعلم القوائم المالية والتحليل المالي</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.4.0/css/all.min.css" rel="stylesheet" />
        <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;600;700;900&family=Tajawal:wght@400;500;700;900&display=swap" rel="stylesheet" />
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <link href="/static/style.css" rel="stylesheet" />
      </head>
      <body class="bg-slate-50 text-slate-800 font-sans">{children}</body>
    </html>
  )
})
