kiloton: kiloton-worker frontend.cr frontend/*.cr common/*.cr shard.lock
	crystal build frontend.cr -o $@

kiloton-worker: backend.cr backend/*.cr common/*.cr app/controllers/*.cr app/*.cr shard.lock
	crystal build backend.cr -o $@

clean:
	rm kiloton kiloton-worker
