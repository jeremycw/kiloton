require "baked_file_system"

class Vfs
  extend BakedFileSystem

  bake_folder "../bake"
end
