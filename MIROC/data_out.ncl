load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; SND
file1 = addfile("snd_regrid_ccsm.nc", "w")

lat1 = file1->lat
lon1 = file1->lon
tas1 = file1->data

nah = tas1@_FillValue
print(nah)

sf = addfile("re_sftlf.nc", "r")
sft = sf->data

snd1 = new((/128, 256/), float, "No_FillValue")
snd1@longtime = "Snow Depth of CCSM"
snd1@units = "m"
snd1!0 = "lat"
snd1!1 = "lon"
snd1&lat  = new((/128/), double, "No_FillValue")
snd1&lon  = new((/256/), double, "No_FillValue")
snd1&lat = lat1
snd1&lon = lon1

; calculate the trend
opt = True
;opt@return_trend = False
do i = 0, 127
  do j = 0, 255
    ; slope
    tm2 = trend_manken(tas1(:, i, j), opt, 0)
    snd1(i, j) = tm2(1)
    if(snd1(i, j) .le. 0)
      snd1(i, j) = 0
    end if
  end do
end do

snd2 = where(sft .eq. 0, nah, snd1)
snd2@_FillValue = nah
snd2!0 = "lat"
snd2!1 = "lon"
snd2&lat  = new((/128/), double, "No_FillValue")
snd2&lon  = new((/256/), double, "No_FillValue")
snd2&lat = lat1
snd2&lon = lon1
copy_VarMeta(snd1, snd2)

system("rm -f snd_out_final.nc")
out1 = addfile("snd_out_final.nc", "c")
out1->data = snd2
open1 = addfile("snd_out_final.nc", "r")

; BLC
file2 = addfile("balance.nc", "w")

lat2 = file2->lat
lon2 = file2->lon
tas2 = file2->data

blc1 = new((/128, 256/), float, "No_FillValue")
blc1@longtime = "Snow Depth of CCSM"
blc1@units = "m"
blc1!0 = "lat"
blc1!1 = "lon"
blc1&lat  = new((/128/), double, "No_FillValue")
blc1&lon  = new((/256/), double, "No_FillValue")
blc1&lat = lat2
blc1&lon = lon2

; Cut the code which smaller than 0 / mm to m
do i = 0, 127
  do j = 0, 255
    cur = tas2(i, j)
    if(cur .le. 0)
      cur = 0
    end if
    blc1(i, j) = cur / 10000.
  end do
end do

blc2 = where(sft .eq. 0, nah, blc1)
blc2@_FillValue = nah
copy_VarMeta(blc1, blc2)

system("rm -f blc_out_final.nc")
out2 = addfile("blc_out_final.nc", "c")
out2->data = blc2
open2 = addfile("blc_out_final.nc", "r")

end
