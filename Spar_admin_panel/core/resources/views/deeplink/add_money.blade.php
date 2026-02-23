<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Money - Rise</title>
    <style>
        :root {
            color-scheme: light dark;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            margin: 0;
            padding: 24px;
            background: #0f172a;
            color: #f8fafc;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            text-align: center;
        }
        .card {
            background: rgba(15, 23, 42, 0.85);
            border-radius: 16px;
            padding: 32px 24px;
            max-width: 420px;
            width: 100%;
            box-shadow: 0 20px 45px rgba(15, 23, 42, 0.4);
            backdrop-filter: blur(12px);
        }
        h1 {
            margin-bottom: 12px;
            font-size: 24px;
        }
        p {
            margin: 8px 0;
            line-height: 1.6;
            color: rgba(248, 250, 252, 0.8);
        }
        .cta {
            display: inline-block;
            margin-top: 18px;
            padding: 14px 26px;
            border-radius: 999px;
            background: #0087ff;
            color: #ffffff;
            text-decoration: none;
            font-weight: 600;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .cta:hover, .cta:focus-visible {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0, 135, 255, 0.35);
        }
        .fallback {
            margin-top: 28px;
            display: none;
        }
        .fallback.visible {
            display: block;
        }
        .buttons {
            margin-top: 16px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            justify-content: center;
        }
        .buttons a {
            padding: 12px 18px;
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.35);
            color: #e2e8f0;
            text-decoration: none;
            transition: background 0.2s ease, color 0.2s ease;
        }
        .buttons a:hover, .buttons a:focus-visible {
            background: rgba(148, 163, 184, 0.2);
            color: #ffffff;
        }
        .small {
            font-size: 13px;
            color: rgba(148, 163, 184, 0.9);
            margin-top: 12px;
        }
    </style>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const appUrl = @json($appScheme);
            const fallbackCard = document.getElementById('fallback-card');

            try {
                window.location.href = appUrl;
            } catch (err) {
                console.error('Deep link redirect failed', err);
            }

            setTimeout(function () {
                fallbackCard.classList.add('visible');
            }, 1600);
        });
    </script>
</head>
<body>
<main class="card">
    <h1>Opening Add Money</h1>
    <p>Hang tight, we&apos;re redirecting you to the Rise app so you can top up your plan.</p>
    <p>If nothing happens in a couple of seconds, tap the button below.</p>

    <a class="cta" href="{{ $appScheme }}">Try Again</a>

    <section id="fallback-card" class="fallback">
        <p><strong>Still not opening?</strong></p>
        <p>Install or update the app, then come back and try again.</p>
        <div class="buttons">
            @if(!empty($androidStore))
                <a href="{{ $androidStore }}" rel="noopener">Open Play Store</a>
            @endif
            @if(!empty($iosStore))
                <a href="{{ $iosStore }}" rel="noopener">Open App Store</a>
            @endif
        </div>
        <p class="small">Plan ID: {{ $planId }} @if(!empty($investId)) • Investment ID: {{ $investId }} @endif</p>
    </section>
</main>
</body>
</html>

