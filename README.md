# README

### Dependancies

```
brew update
brew install rbenv
rbenv install 2.4
brew install redis
brew install influxdb
```

### Database

```
bundle exec rails db:create
bundle exec rails db:gis:setup
bundle exec rails db:migrate
bundle exec rails db:seed
```

### Start server

```
DEPLOYMENT_TYPE=local \
INFLUXDB_URL=http://localhost:8086 \
CLOUDINARY_URL=cloudinary://299946174867359:WFWCszsOAO9_rQB4Y8m48wJk_Mk@starlove-local \
ONE_SIGNAL_APP_ID=c6be5287-c3f7-4583-897a-387e1b7a096b \
ONE_SIGNAL_API_KEY=NWNiMGUzOTktNDViMS00MWJkLTg0MTgtZTRlNGU0OTIzOTc0 \
bundle exec rails s
```

### Start background worker

```
redis-server /usr/local/etc/redis.conf
DEPLOYMENT_TYPE=local \
INFLUXDB_URL=http://localhost:8086 \
CLOUDINARY_URL=cloudinary://299946174867359:WFWCszsOAO9_rQB4Y8m48wJk_Mk@starlove-local \
ONE_SIGNAL_APP_ID=c6be5287-c3f7-4583-897a-387e1b7a096b \
ONE_SIGNAL_API_KEY=NWNiMGUzOTktNDViMS00MWJkLTg0MTgtZTRlNGU0OTIzOTc0 \
bundle exec rails resque:work QUEUE='*'
```

### Influx

Start influx

```
influxd
```

Create initial databases

```
DEPLOYMENT_TYPE=local INFLUXDB_URL=http://localhost:8086 bundle exec rake influx:setup
```

Destroy influx data

```
DEPLOYMENT_TYPE=local INFLUXDB_URL=http://localhost:8086 bundle exec rake influx:destroy
```

### Specs

```
DEPLOYMENT_TYPE=local bundle exec rspec
```

### Simulations

Simulate a assembly and parliament election for given state

```
DEPLOYMENT_TYPE=local SIMULATION_MODE=1 INFLUXDB_URL=http://localhost:8086 CLOUDINARY_URL=cloudinary://299946174867359:WFWCszsOAO9_rQB4Y8m48wJk_Mk@starlove-local bundle exec rake "simulation:election[pb]"
```

Wire up images for the above run simulation, supported user, leader, issue

```
DEPLOYMENT_TYPE=local SIMULATION_MODE=1 INFLUXDB_URL=http://localhost:8086 CLOUDINARY_URL=cloudinary://299946174867359:WFWCszsOAO9_rQB4Y8m48wJk_Mk@starlove-local bundle exec rake "simulation:rework_images[user, pb]"
```

```
DEPLOYMENT_TYPE=local SIMULATION_MODE=1 INFLUXDB_URL=http://localhost:8086 CLOUDINARY_URL=cloudinary://299946174867359:WFWCszsOAO9_rQB4Y8m48wJk_Mk@starlove-local bundle exec rake "simulation:rework_images[leader, pb]"
```

```
DEPLOYMENT_TYPE=local SIMULATION_MODE=1 INFLUXDB_URL=http://localhost:8086 CLOUDINARY_URL=cloudinary://299946174867359:WFWCszsOAO9_rQB4Y8m48wJk_Mk@starlove-local bundle exec rake "simulation:rework_images[post, pb]"
```

Wire up issues for the above run simulation

```
DEPLOYMENT_TYPE=local SIMULATION_MODE=1 INFLUXDB_URL=http://localhost:8086 CLOUDINARY_URL=cloudinary://299946174867359:WFWCszsOAO9_rQB4Y8m48wJk_Mk@starlove-local bundle exec rake "simulation:issues[pb]"
```

Create election for an assembly do voting, create issues and polls and perform Voting
options: assembly & parliamentary

For parliamentary elections only election voting is simulated

```
DEPLOYMENT_TYPE=local SIMULATION_MODE=1 INFLUXDB_URL=http://localhost:8086 CLOUDINARY_URL=cloudinary://299946174867359:WFWCszsOAO9_rQB4Y8m48wJk_Mk@starlove-local bundle exec rake "simulation:election_and_issues[pb, assembly, amritsar central]"
```

```
DEPLOYMENT_TYPE=local SIMULATION_MODE=1 INFLUXDB_URL=http://localhost:8086 CLOUDINARY_URL=cloudinary://299946174867359:WFWCszsOAO9_rQB4Y8m48wJk_Mk@starlove-local bundle exec rake "simulation:election_and_issues[pb, parliamentary, amritsar]"
```

Setup elections, voting, posts in parliament and its assembly

```
DEPLOYMENT_TYPE=local SIMULATION_MODE=1 INFLUXDB_URL=http://localhost:8086 CLOUDINARY_URL=cloudinary://299946174867359:WFWCszsOAO9_rQB4Y8m48wJk_Mk@starlove-local bundle exec rake "simulation:election_and_issues_parliament[ts, malkajgiri]"
```

Setup simulation

```
DEPLOYMENT_TYPE=local SIMULATION_MODE=1 INFLUXDB_URL=http://localhost:8086 CLOUDINARY_URL=cloudinary://299946174867359:WFWCszsOAO9_rQB4Y8m48wJk_Mk@starlove-local bundle exec rake "simulation:setup"
```

Destroy entire simulation

```
DEPLOYMENT_TYPE=local SIMULATION_MODE=1 INFLUXDB_URL=http://localhost:8086 CLOUDINARY_URL=cloudinary://299946174867359:WFWCszsOAO9_rQB4Y8m48wJk_Mk@starlove-local bundle exec rake "simulation:destroy_all"
```
