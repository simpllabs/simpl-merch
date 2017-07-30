class AddInventoryJob < ProgressJob::Base
  def initialize(file_path)
    @file_path = file_path
  end

  def perform
        
        male_inventory = MaleInventory.all.first
        female_inventory = FemaleInventory.all.first

        arr_of_arrs = CSV.read(@file_path)

        #male table
        male_inventory.black_s    += arr_of_arrs[1][1].to_i
        male_inventory.black_m    += arr_of_arrs[2][1].to_i
        male_inventory.black_l    += arr_of_arrs[3][1].to_i
        male_inventory.black_xl   += arr_of_arrs[4][1].to_i
        male_inventory.black_2xl  += arr_of_arrs[5][1].to_i
        male_inventory.black_3xl  += arr_of_arrs[6][1].to_i

        male_inventory.white_s    += arr_of_arrs[1][2].to_i
        male_inventory.white_m    += arr_of_arrs[2][2].to_i
        male_inventory.white_l    += arr_of_arrs[3][2].to_i
        male_inventory.white_xl   += arr_of_arrs[4][2].to_i
        male_inventory.white_2xl  += arr_of_arrs[5][2].to_i
        male_inventory.white_3xl  += arr_of_arrs[6][2].to_i

        male_inventory.navy_s     += arr_of_arrs[1][3].to_i
        male_inventory.navy_m     += arr_of_arrs[2][3].to_i
        male_inventory.navy_l     += arr_of_arrs[3][3].to_i
        male_inventory.navy_xl    += arr_of_arrs[4][3].to_i
        male_inventory.navy_2xl   += arr_of_arrs[5][3].to_i
        male_inventory.navy_3xl   += arr_of_arrs[6][3].to_i

        male_inventory.green_s    += arr_of_arrs[1][4].to_i
        male_inventory.green_m    += arr_of_arrs[2][4].to_i
        male_inventory.green_l    += arr_of_arrs[3][4].to_i
        male_inventory.green_xl   += arr_of_arrs[4][4].to_i
        male_inventory.green_2xl  += arr_of_arrs[5][4].to_i
        male_inventory.green_3xl  += arr_of_arrs[6][4].to_i

        male_inventory.red_s      += arr_of_arrs[1][5].to_i
        male_inventory.red_m      += arr_of_arrs[2][5].to_i
        male_inventory.red_l      += arr_of_arrs[3][5].to_i
        male_inventory.red_xl     += arr_of_arrs[4][5].to_i
        male_inventory.red_2xl    += arr_of_arrs[5][5].to_i
        male_inventory.red_3xl    += arr_of_arrs[6][5].to_i

        #female table
        female_inventory.black_xs += arr_of_arrs[9][1].to_i
        female_inventory.black_s  += arr_of_arrs[10][1].to_i
        female_inventory.black_m  += arr_of_arrs[11][1].to_i
        female_inventory.black_l  += arr_of_arrs[12][1].to_i
        female_inventory.black_xl += arr_of_arrs[13][1].to_i
        female_inventory.black_2xl+= arr_of_arrs[14][1].to_i

        female_inventory.white_xs += arr_of_arrs[9][2].to_i
        female_inventory.white_s  += arr_of_arrs[10][2].to_i
        female_inventory.white_m  += arr_of_arrs[11][2].to_i
        female_inventory.white_l  += arr_of_arrs[12][2].to_i
        female_inventory.white_xl += arr_of_arrs[13][2].to_i
        female_inventory.white_2xl+= arr_of_arrs[14][2].to_i

        female_inventory.navy_xs  += arr_of_arrs[9][3].to_i
        female_inventory.navy_s   += arr_of_arrs[10][3].to_i
        female_inventory.navy_m   += arr_of_arrs[11][3].to_i
        female_inventory.navy_l   += arr_of_arrs[12][3].to_i
        female_inventory.navy_xl  += arr_of_arrs[13][3].to_i
        female_inventory.navy_2xl += arr_of_arrs[14][3].to_i

        female_inventory.green_xs += arr_of_arrs[9][4].to_i
        female_inventory.green_s  += arr_of_arrs[10][4].to_i
        female_inventory.green_m  += arr_of_arrs[11][4].to_i
        female_inventory.green_l  += arr_of_arrs[12][4].to_i
        female_inventory.green_xl += arr_of_arrs[13][4].to_i
        female_inventory.green_2xl+= arr_of_arrs[14][4].to_i

        female_inventory.red_xs   += arr_of_arrs[9][5].to_i
        female_inventory.red_s    += arr_of_arrs[10][5].to_i
        female_inventory.red_m    += arr_of_arrs[11][5].to_i
        female_inventory.red_l    += arr_of_arrs[12][5].to_i
        female_inventory.red_xl   += arr_of_arrs[13][5].to_i
        female_inventory.red_2xl  += arr_of_arrs[14][5].to_i

        male_inventory.save
        female_inventory.save
  end
end