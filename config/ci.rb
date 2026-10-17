# Run using bin/ci
# Keep these steps in sync with .github/workflows/ci.yml so that a local pass means a CI pass.
# bin/ci also runs automatically before `git push` via .githooks/pre-push (enabled by bin/setup).

CI.run do
  step "Style: Ruby", "bin/rubocop"

  # Fetch the latest advisory database first; a stale local copy hides vulnerabilities CI will report.
  step "Security: Gem audit", "bin/bundler-audit check --update"
  # bin/brakeman runs with --ensure-latest, so this also fails when a newer Brakeman is released.
  step "Security: Brakeman code analysis", "bin/brakeman --no-pager"

  step "Build: Assets", "npm run build && npm run build:css"
  step "Tests: RSpec", "env RAILS_ENV=test bin/rails db:test:prepare && bundle exec rspec"
end
