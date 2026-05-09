<p align="center">
  <img src="public/assets/images/logo.png" width="200" alt="OpenBookList Logo">
</p>

<h1 align="center">OpenBookList</h1>

<p align="center">
  <strong>Your personal, self-hosted bookmark manager — clean, fast, and fully yours.</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#self-hosting">Self-Hosting</a> •
  <a href="#configuration">Configuration</a> •
  <a href="#api">API</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#support">Support</a>
</p>

---

## What is OpenBookList?

OpenBookList is a modern, open-source bookmark manager designed for people who want to **own their data**. No third-party syncing services, no tracking, no subscriptions — just a beautiful interface for saving, organizing, and rediscovering the links that matter to you.

Whether you're a developer curating documentation, a researcher collecting references, or someone who simply saves too many tabs — OpenBookList gives you a **private, self-hosted home for all your bookmarks**.

## Features

- **Bookmark Management** — Save links with auto-fetched metadata (title, description, image). Edit, delete, and favorite your bookmarks.
- **Categories & Tags** — Organize bookmarks into categories and apply multiple tags for flexible filtering.
- **Favorites** — Mark your most important bookmarks and access them instantly.
- **Search** — Full-text search across all your saved bookmarks.
- **Recently Saved** — Quick access to your latest additions.
- **Multi-User Support** — Enable multi-user mode and let each user manage their own bookmarks privately.
- **API Access** — Generate personal access tokens to interact with your bookmarks programmatically via the Sanctum-powered API.
- **AI Configuration** — Configure AI settings from the dashboard to enhance your workflow.
- **OTP Verification** — Secure registration and password reset with one-time password verification.
- **Modern SPA Experience** — No page reloads. Fully client-side rendered with Inertia.js and Vue 3.
- **Responsive Design** — Works beautifully on desktop, tablet, and mobile.

## Tech Stack

| Layer      | Technology                                         |
| ---------- | -------------------------------------------------- |
| Backend    | [Laravel 12](https://laravel.com)                  |
| Frontend   | [Vue 3](https://vuejs.org) + [Inertia.js v2](https://inertiajs.com) |
| Styling    | [Tailwind CSS v4](https://tailwindcss.com)         |
| Auth       | [Laravel Sanctum](https://laravel.com/docs/sanctum)|
| Database   | MySQL (default) — any Laravel-supported DB works   |
| Build Tool | [Vite](https://vite.dev)                           |

## Self-Hosting

### Requirements

- **PHP** >= 8.2
- **Composer**
- **Node.js** >= 18 & **npm**
- **MySQL** (or any Laravel-supported database: PostgreSQL, SQLite, SQL Server)
- A web server (Apache, Nginx, [Laravel Herd](https://herd.laravel.com), [Laragon](https://laragon.org), etc.)

### Quick Start

**1. Clone the repository**

```bash
git clone https://github.com/aphoe/openbooklist.git
cd openbooklist
```

**2. Run the setup script**

The included setup script will install PHP and JS dependencies, generate your app key, run migrations, and build the frontend in one command:

```bash
composer setup
```

**3. Configure your environment**

Open `.env` and update the following values:

```dotenv
APP_NAME="OpenBookList"
APP_URL=http://your-domain.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=your_database
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

**4. Start the application**

For local development, run:

```bash
composer run dev
```

This starts the Laravel server, queue worker, and Vite dev server concurrently.

For production, point your web server's document root to the `public/` directory and ensure you've built the frontend assets:

```bash
npm run build
```

### Manual Setup (Step-by-Step)

If you prefer to set things up manually:

```bash
# Install PHP dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Run database migrations
php artisan migrate

# Install JS dependencies
npm install

# Build frontend assets
npm run build
```

### Docker (Laravel Sail)

OpenBookList ships with [Laravel Sail](https://laravel.com/docs/sail) for Docker-based development:

```bash
# Start the containers
./vendor/bin/sail up -d

# Run migrations
./vendor/bin/sail artisan migrate

# Build frontend
./vendor/bin/sail npm run build
```

## Configuration

### Multi-User Mode

By default, OpenBookList runs in **single-user mode**. To enable multi-user registration:

```dotenv
MULTI_USER=true
```

### AI-Powered Descriptions (OpenRouter)

OpenBookList can automatically generate descriptions for your bookmarks using AI. This is powered by [OpenRouter](https://openrouter.ai), which gives you access to a wide range of AI models (GPT-4o, Claude, Gemini, Llama, and more) through a single API key.

To enable this feature, get an API key from [openrouter.ai/keys](https://openrouter.ai/keys) and add it to your `.env`:

```dotenv
OPENROUTER_KEY=sk-or-v1-your-key-here
```

Once configured, head to **Settings → AI Configuration** in the app to:

- Enable automatic description generation for new bookmarks
- Choose your preferred AI model from the full OpenRouter catalog

> Without this key, AI features will be disabled but the rest of the app works perfectly.

### YouTube Metadata (Update)

OpenBookList now has YouTube-aware metadata fetching.

When saving or re-fetching a bookmark:

- If the URL is a YouTube link and `YOUTUBE_API_KEY` is configured, OpenBookList uses **YouTube Data API v3** to fetch the title, description, and thumbnail.
- It always selects the **largest available thumbnail URL**.
- It requests localized metadata using the authenticated user's language, with `en` as the fallback.
- If no API key is configured (or YouTube lookup fails), OpenBookList falls back to normal metadata scraping.

Add this to your `.env`:

```dotenv
YOUTUBE_API_KEY=your-youtube-data-api-v3-key
```

#### How to get a YouTube Data API v3 key (Google Cloud Console)

1. Go to <https://console.cloud.google.com/> and create/select a project.
2. Open **APIs & Services → Library**.
3. Search for **YouTube Data API v3** and click **Enable**.
4. Go to **APIs & Services → Credentials**.
5. Click **Create Credentials → API key**.
6. Copy the generated key into your `.env` as `YOUTUBE_API_KEY`.
7. (Recommended) Click **Restrict key** and apply restrictions:
   - **Application restriction**: HTTP referrers (web) or IP addresses (server), depending on your deployment.
   - **API restriction**: limit to **YouTube Data API v3**.

### Screenshot Capture (spatie/laravel-screenshot)

OpenBookList uses [`spatie/laravel-screenshot`](https://spatie.be/docs/laravel-screenshot/v1/introduction) to generate website screenshots for bookmark images.

If you are upgrading from an older OpenBookList version and do not have the package yet, install it (and the Browsershot dependency):

```bash
composer require spatie/laravel-screenshot
composer require spatie/browsershot
```

Optionally publish the config file so you can tune driver settings:

```bash
php artisan vendor:publish --tag=screenshot-config
```

#### Browsershot driver (default)

Browsershot is the default driver and runs Chromium via Node.js.

1. Make sure your server has Node.js and the dependencies required by Browsershot.
2. Follow the Browsershot requirements guide: <https://spatie.be/docs/browsershot/v4/requirements>
3. Configure `.env` as needed (minimum example below):

```dotenv
LARAVEL_SCREENSHOT_DRIVER=browsershot

# Optional binary overrides (set only when auto-detection fails)
LARAVEL_SCREENSHOT_NODE_BINARY=
LARAVEL_SCREENSHOT_NPM_BINARY=
LARAVEL_SCREENSHOT_CHROME_PATH=
LARAVEL_SCREENSHOT_NODE_MODULES_PATH=
LARAVEL_SCREENSHOT_NO_SANDBOX=false
```

#### Cloudflare driver

Cloudflare uses Browser Rendering API and does not require Node.js/Chrome on your app server.

1. Create a Cloudflare API token with `Account.Browser Rendering` permission.
2. Find your Cloudflare Account ID.
3. Configure `.env`:

```dotenv
LARAVEL_SCREENSHOT_DRIVER=cloudflare
CLOUDFLARE_API_TOKEN=your-api-token
CLOUDFLARE_ACCOUNT_ID=your-account-id
```

Use Browsershot when you control the host and can install Chromium dependencies. Use Cloudflare when you want simpler server setup or managed browser rendering.

### Mail

Configure a mail driver for password resets and OTP verification:

```dotenv
MAIL_MAILER=smtp
MAIL_HOST=smtp.your-provider.com
MAIL_PORT=587
MAIL_USERNAME=your@email.com
MAIL_PASSWORD=your-password
MAIL_FROM_ADDRESS=noreply@your-domain.com
MAIL_FROM_NAME="OpenBookList"
```

### Queue

For production, use a dedicated queue driver (Redis, database, etc.) and run a worker:

```bash
php artisan queue:work
```

## API

OpenBookList includes a **Sanctum-powered API**. Generate personal access tokens from **Settings → Access Tokens** in the app, then use them to interact with your bookmarks programmatically:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://your-domain.com/api/user
```

## Running Tests

```bash
php artisan test
```

## Contributing

Contributions are welcome! Whether it's a bug fix, feature request, or documentation improvement — open an issue or submit a pull request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please run `vendor/bin/pint` before submitting to ensure your code follows the project's style.

## Need Help Setting Up?

**We offer paid consultation and professional setup services.** If you'd like a hands-off deployment, custom integrations, or expert guidance tailored to your infrastructure — we're here for you.

📧 **Reach out:** [aphoextra@gmail.com](mailto:aphoextra@gmail.com)

## Support the Project

OpenBookList is built and maintained with 💛 in spare time. If it saves you time, keeps you organized, or just makes your day a little better — consider buying me a coffee. Every contribution fuels late-night commits and new features.

<p align="center">
  <a href="https://buymeacoffee.com/aphoe" target="_blank">
    <img src="public/assets/images/bmc.png" height="60" alt="Buy Me A Coffee">
  </a>
</p>

**👉 [buymeacoffee.com/aphoe](https://buymeacoffee.com/aphoe)**

Your support — whether it's a coffee, a star ⭐ on GitHub, or sharing the project — means the world. Thank you for being part of this.

## License

OpenBookList is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).