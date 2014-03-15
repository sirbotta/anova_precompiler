require 'csv'
require 'yaml'
groups = YAML.load_file('groups.yml')


### labels per classificare dalla riga d'imput nel csv
@row_lbl= {}
groups.each do | key , group |
  group.each do | label, row|
    @row_lbl[row]= label
  end
end 

### labels associate ad un particolare gruppo
@groups_names= []
@group_lbl= Hash.new []
groups.each do | key , group |
  @groups_names.push(key)
  group.each do | label, row|
    @group_lbl[key]+= [].push(label) 
  end
end

### funzione che data un hash di lbl: value restituisce la media di un certo gruppo passato come array di lables
def lblmean(data,lblgroup)
   sum=0.00
   lblgroup.each do |lbl|
     sum+= data[lbl].to_f
   end
   return sum / lblgroup.length
end


def a_compiler(file_name)

  ### trucco per crare hash di hash
  raw = Hash.new do |hash,key| 
      hash[key] = {}
  end
 
  ### leggo i dati, rigiro i subject in righe e associo correttamente alla riga la label (i subject partono da 1, non zero)
  CSV.foreach("input/#{file_name}") do |row|
    row.each_with_index do | data , subject|
      if(@row_lbl.has_key?($INPUT_LINE_NUMBER))
        raw[subject+1].merge!(@row_lbl[$INPUT_LINE_NUMBER] => data)
      end
    end
  end



  ### preparo l'output facendo le medie per gruppi di di ogni soggetto
  output = Hash.new []
  raw.each do |subject, value|
     #printf "soggetto #{subject} |"
     @group_lbl.each do |group, labels|
       #printf "#{group}-> #{lblmean(value,labels)} |"
       output[subject] += [].push(lblmean(value,labels))
     end
     #printf "\n"
  end

  ### scrivo il file csv nella cartella output
  CSV.open("output/#{file_name.chomp('.xls')}_avg_agg.csv", 'w') do |csv| 
    csv << @groups_names # Add new headers 
    output.each do |subject , row| 
      csv.puts row
    end
  end
end


file_to_convert = Dir.entries('input/')
#puts file_to_convert
file_to_convert.reject! {|item| item == '.'  || item == '..' || item == '.gitignore'}
file_to_convert.each do | file |
  begin
    a_compiler(file)
    puts "compilato il file #{file}"
  rescue
    puts "#{file} non e' leggibile"
  end
end
