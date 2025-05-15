#!/bin/bash
set -e

echo "🚀 Running database migrations..."
bundle exec rails db:migrate

echo "🟢 Starting Rails server..."
bundle exec rails server -b 0.0.0.0 -p 8000