
require 'rubygems'
require 'test/unit'
require 'rdbi/driver/mysql'
require 'test/unit'

class Test_DbaccessMySQL < Test::Unit::TestCase
  # Compare one row with expecting hash data 
  def compare_row(data, row)
    
    data.each do |key, value|
      
      if value == "NULL"
        expecting_value = nil
      else
        expecting_value = value
      end
      
      if row[key].instance_of?(BigDecimal)
        assert_equal(BigDecimal.new(expecting_value), row[key], "#{key} column mismatch: #{value.to_s} <> #{row[key].to_s}")
      elsif row[key].instance_of?(Float)
        assert_equal(expecting_value.to_f, row[key], "#{key} column mismatch: #{value.to_s} <> #{row[key].to_s}")
      elsif row[key].instance_of?(Time) or row[key].instance_of?(DateTime) 
        assert_equal(expecting_value.to_s, row[key].strftime("%Y-%m-%d %H:%M:%S")[0, expecting_value.to_s.size], "#{key} column mismatch: #{value.to_s} <> #{row[key].strftime("'%Y-%m-%d %H:%M:%S'")}")
      else
        assert_equal(expecting_value.to_s, row[key].to_s.strip[0, expecting_value.to_s.size], "#{key} column mismatch: #{value.class.to_s}->#{value.to_s} <> #{row[key].class.to_s}->#{row[key].to_s}")
      end
    end
  end
  
  def setup
    %x{mysql -u root -e "drop database mysql_test"}
    %x{mysql -u root -e "source setup_test_db.sql;"}
    
    base_args = {
      :host     => "localhost",
      :hostname => "localhost",
      :port     => 3306,
      :username => "root",
      :password => "",
      :database => "mysql_test",
    }

    @dba = RDBI.connect(:MySQL, base_args)
  end

  def test_all
    data = {
      "table1_id" => "1",
      "column1" => "-1",
      "column2" => "-1",
      "column3" => "-1",
      "column4" => "-1",
      "column5" => "-1",
      "column6" => "-1",
#      "column7" => "-1.11",
      "column8" => "-1.11",
      "column9" => "1"
    }
    
    @dba.execute("INSERT INTO table1 (column5, column6, table1_id, column7, column8, column9, column1, column2, column3, column4) values (-1, -1, 1, -1.11, -1.11, 1, -1, -1, -1, -1)")
    
    result_set = @dba.execute("select * from table1 where table1_id = 1")
    assert_equal(1, result_set.count)
    data.delete("column9")
    compare_row(data, result_set.as(:Struct).fetch(:first))
    
    data = {
      "table1_id" => "1",
      "column1" => "1",
      "column2" => "1",
      "column3" => "1",
      "column4" => "1",
      "column5" => "1",
      "column6" => "1",
#      "column7" => "1.11",
      "column8" => "1.11",
      "column9" => "11"
    }
    
    @dba.execute("UPDATE table1 SET column5=1, column6=1, column7=1.11, column8=1.11, column9=11, column1=1, column2=1, column3=1, column4=1 WHERE table1_id=1")
    result_set = @dba.execute("select * from table1 where table1_id = 1")
    assert_equal(1, result_set.count)
    data.delete("column9")
    compare_row(data, result_set.as(:Struct).fetch(:first))
    
    data = {
      "table2_id" => "1",
      "table1_id" => "1",
      "column1" => "-1",
      "column2" => "NULL",
      "column3" => "-1",
      "column4" => "-1",
      "column5" => "-1",
      "column6" => "-1",
      "column7" => "-1.11",
      "column8" => "-1.11",
      "column9" => "1",
      "column10" => "1",
      "column11" => "1",
      "column12" => "1"
    }
    
    @dba.execute("INSERT INTO table2 (column5, column10, column6, column11, table1_id, column7, column12, table2_id, column8, column9, column1, column2, column3, column4) values ('-1', '1', '-1', '1', 1, '-1.11', '1', 1, '-1.11', '1', '-1', NULL, '-1', '-1')")
    
    result_set = @dba.execute("select * from table2 where table2_id = 1")
    assert_equal(1, result_set.count)
    compare_row(data, result_set.as(:Struct).fetch(:first))
    
    data = {
      "table2_id" => "1",
      "column1" => "1",
      "column2" => "1",
      "column3" => "1",
      "column4" => "1",
      "column5" => "1",
      "column6" => "1",
      "column7" => "1.11",
      "column8" => "1.11",
      "column9" => "-1",
      "column10" => "NULL",
      "column11" => "-1",
      "column12" => "-1"
    }
    
    @dba.execute("UPDATE table2 SET column5='1', column10=NULL, column11='-1', column6='1', column12='-1', column7='1.11', column8='1.11', column9='-1', column1='1', column2='1', column3='1', column4='1' WHERE table2_id=1")
    result_set = @dba.execute("select * from table2 where table2_id = 1")
    assert_equal(1, result_set.count)
    compare_row(data, result_set.as(:Struct).fetch(:first))
    
    data = {
      "table3_id" => "1",
      "table2_id" => "1",
      "column1" => "ABC",
      "column2" => "2011-02-12",
      "column3" => "12:13:16",
      "column4" => "2011-02-12 12:13:16",
      "column5" => "2011-02-12 12:13:16",
      "column6" => "2011",
      "column7" => "2"
    }
    
    @dba.execute("INSERT INTO table3 (column5, column6, column7, table2_id, column1, column2, column3, table3_id, column4) values ('2011-02-12 12:13:16', '2011', 2, 1, 'ABC', '2011-02-12', '12:13:16', 1, '2011-02-12 12:13:16')")
    
#    result_set = @dba.execute("select * from table3 where table3_id = 1")
#    assert_equal(1, result_set.count)
#    data["column7"] = "DEF"
#    data["column3"] = Time.now.strftime("%Y-%m-%d ") + data["column3"]
#    compare_row(data, result_set.as(:Struct).fetch(:first))
    
    data = {
      "table3_id" => "1",
      "table2_id" => "1",
      "column1" => "3",
      "column2" => "2010-02-12",
      "column3" => "02:13:16",
      "column4" => "2011-01-12 12:13:16",
      "column5" => "2011-01-12 12:13:16",
      "column6" => "2010",
      "column7" => "ABC"
    }
    
    @dba.execute("UPDATE table3 SET column5='2011-01-12 12:13:16', column6='2010', column7='ABC', table2_id=1, column1=3, column2='2010-02-12', column3='02:13:16', column4='2011-01-12 12:13:16' WHERE table3_id=1")
    
#    result_set = @dba.execute("select * from table3 where table3_id = 1")
#    assert_equal(1, result_set.count)
#    data["column1"] = "HIJ"
#    data["column3"] = Time.now.strftime("%Y-%m-%d ") + data["column3"]
#    compare_row(data, result_set.as(:Struct).fetch(:first))
#    
    
    data = {
      "table4_id" => "1",
      "table3_id" => "1",
      "table2_id" => "1",
      "column1" => "ABC",
      "column2" => "abc\"\'"
    }
    
#    @dba.execute("INSERT INTO table4 (table2_id, column1, column2, table4_id, table3_id) values (1, 'ABC', 'abc\"\'', 1, 1)")
#    
#    result_set = @dba.execute("select * from table4 where table4_id = 1")
#    assert_equal(1, result_set.count)
#    compare_row(data, result_set.as(:Struct).fetch(:first))
#    
#    data = {
#      "table3_id" => "1",
#      "table2_id" => "1",
#      "column1" => "1",
#      "column2" => "def" 
#    }
#    
#    @dba.execute("UPDATE table4 SET column2='def' WHERE table2_id=1 AND column1=1 AND table3_id=1")
#    
#    result_set = @dba.execute("select * from table4 where table4_id = 1")
#    assert_equal(1, result_set.count)
#    data["column1"] = "ABC"
#    compare_row(data, result_set.as(:Struct).fetch(:first))
#    
#    data = {
#      "table3_id" => "1",
#      "table2_id" => "1",
#      "column1" => "1"
#    }
    
    @dba.execute("DELETE FROM table4  WHERE table2_id=1 AND column1=1 AND table3_id=1")
    
    assert_equal(0, @dba.execute("select * from table4 where table4_id = 1").count)
    
    data = {
      "table3_id" => "1"
    }
    
    @dba.execute("DELETE FROM table3  WHERE table3_id=1")
    
    assert_equal(0, @dba.execute("select * from table3 where table3_id = 1").count)
        
    data = {
      "table2_id" => "1"
    }
    
    @dba.execute("DELETE FROM table2  WHERE table2_id=1")
    
    assert_equal(0, @dba.execute("select * from table2 where table2_id = 1").count)
    
    data = {
      "table1_id" => "1"
    }
    
    @dba.execute("DELETE FROM table1  WHERE table1_id=1")
    
    assert_equal(0, @dba.execute("select * from table1 where table1_id = 1").count)
  end
  
  def teardown
    if @dba
      @dba.disconnect()
    end
  end
end
