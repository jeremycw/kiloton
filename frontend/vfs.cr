require "baked_file_system"

class Kiloton::Vfs
  extend BakedFileSystem

  bake_folder "../bake"
end
