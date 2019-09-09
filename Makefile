kiloton: bake/kiloton-worker frontend.cr frontend/*.cr common/*.cr shard.lock
	crystal build frontend.cr -o $@ --warnings=all

bake/kiloton-worker: backend.cr backend/*.cr common/*.cr app/controllers/*.cr app/*.cr shard.lock | bake
	crystal build backend.cr -o $@ --warnings=all

bake:
	@mkdir $@

clean:
	@rm -rf kiloton *.dwarf bake

run: kiloton
	./kiloton

.PHONY: clean run
