# Training History

A workout tracking web application with an interval timer for circuit training.

## Features

- **Workout Calendar**: Track your daily training with a monthly calendar view
- **Interval Timer**: Circuit training timer with customizable exercise presets
- **Exercise Presets**: Create and manage workout routines with multiple exercises
- **Google OAuth**: Secure authentication via Google account
- **Mobile-friendly**: Responsive design optimized for smartphones
- **Wake Lock**: Prevents screen from dimming during timer sessions (iOS Safari 16.4+)

## Tech Stack

- Ruby 4.0.7
- Rails 8.1.4
- Hotwire (Turbo + Stimulus)
- TailwindCSS
- SQLite (development) / PostgreSQL (production)
- Google OAuth 2.0

## Setup

### Prerequisites

- Ruby 4.0.7
- Node.js
- Bundler

### Installation

```bash
# Clone the repository
git clone https://github.com/shoutm/training-history.git
cd training-history

# Install dependencies
bundle install
npm install

# Setup database
bin/rails db:setup

# Enable the pre-push hook that runs bin/ci (also done by bin/setup)
git config core.hooksPath .githooks

# Setup credentials (for Google OAuth)
EDITOR="code --wait" bin/rails credentials:edit
```

Add your Google OAuth credentials:

```yaml
google:
  client_id: your_client_id
  client_secret: your_client_secret
```

### Running the app

```bash
# Using foreman (runs Rails server, JS build, and CSS build concurrently)
bin/dev

# Or run each process separately in different terminals:
bin/rails server
npm run build -- --watch
npm run build:css -- --watch
```

Visit http://localhost:3000

## Testing

```bash
bundle exec rspec
```

To run the same checks as GitHub Actions CI (RuboCop, bundler-audit, Brakeman, asset build, RSpec):

```bash
bin/ci
```

`bin/ci` runs automatically before `git push` via `.githooks/pre-push`. Keep `config/ci.rb` in sync with `.github/workflows/ci.yml`.

## Deployment

The app is configured for deployment on Railway with PostgreSQL.

Set the `RAILS_MASTER_KEY` environment variable with the contents of `config/master.key`.

## License

MIT
