/*

==Class: postgresql::ubuntu::v9-1

Parameters:
 $postgresql_data_dir:
    set the data directory path, which is used to store all the databases

Requires:
 - Class["apt::preferences"]

*/
class postgresql::ubuntu::v9-1 inherits postgresql::ubuntu::base {

  $data_dir = $postgresql_data_dir ? {
    "" => "/var/lib/postgresql",
    default => $postgresql_data_dir,
  }

    'precise': {
      package {[
        "libpq-dev",
        "libpq5",
        "postgresql-client-9.1",
        "postgresql-common",
        "postgresql-client-common",
        "postgresql-contrib-9.1"
        ]:
        ensure  => present,
      }

      # re-create the cluster in UTF8
      exec {"pg_createcluster in utf8" :
        command => "pg_dropcluster --stop 9.1 main && pg_createcluster -e UTF8 -d ${data_dir}/9.1/main --start 9.1 main",
        path => "/bin:/usr/bin",
        onlyif => "test \$(su -c \"psql -tA -c 'SELECT count(*)=3 AND min(encoding)=0 AND max(encoding)=0 FROM pg_catalog.pg_database;'\" postgres) = t",
        user => root,
        timeout => 60,
      }
    }

    default: {
      fail "postgresql 9.1 not available for ${operatingsystem}/${lsbdistcodename}"
    }
  }
}

