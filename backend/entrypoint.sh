set -e

mkdir -p tmp/pids
rm -f tmp/pids/server.pid

exec ./bin/rails server -b 0.0.0.0 -p 8000
