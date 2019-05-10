# Kiloton

Kiloton is a web framework for Crystal that is loosley inspired by Ruby on Rails.
It does not aspire to be as featureful as Rails but intends to provide a more comprehensive
out of the box experience for the core components of a web app.

For me this means:

- Compiles to a single static binary for easy deployment
- No need to be running auxilliary services. Infrastructure you need is builtin.
  - No need to run sidekiq or equivalent, scalable job running is builtin.
  - No need to run seperate websocket server because the builtin one will Just Work at scale.
- Seamless horizontal scaling with no need to worry about primary/secondary semantics
  - Cron/Scheduled jobs will be scheduled by one server but executed by many
- Production ready by default
  - Automatically scales vertically on a single machine to the amount of cores available
  - All default behaviour will be scalable. No toy/cute behaviour that needs to changed later.
- First class async workflows
  - Sometimes a business process is more complicated than a single endpoint
  - These highlevel flows should be first class instead of adhoc
