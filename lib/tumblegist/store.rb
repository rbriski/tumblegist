module Tumblegist
  module Store
    extend self

    def conn
      @conn ||= PG.connect Settings[:database].delete_if { | k, v | v.blank? }
    end

    def create_table
      res = conn.exec("select count(*) from information_schema.tables where table_name='%s'" % ["gists"])
      unless res.first["count"].to_i == 0
        $stderr.puts "Table already exists"
        return false
      end
      res = conn.exec("create table gists (id integer, created_at integer)")
    end

    def add id
      created_at = Time.now.to_i
      res = conn.exec("insert into gists (created_at, id) values (%i, %i)" % [created_at, id])
    end

    def ids
      res = conn.exec("select id from gists")
      res.map { | pair | pair['id'].to_i }
    end

    def expire
      cutoff = Time.now.to_i - Settings[:dedup_expiration]
      res = conn.exec('delete from gists where created_at < %i' % [cutoff])
    end
  end
end