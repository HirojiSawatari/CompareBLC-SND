load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Grade -2:Null; -1:mass balance<-1cm/yr and ice sheet=1; 0:mass balance=[-1, 1]cm/yr;

begin

file1 = addfile("balance.nc", "w")

lat1 = file1->lat
lon1 = file1->lon
blc1 = file1->data

nah = blc1@_FillValue
print(nah)

sf = addfile("re_sftlf.nc", "r")
sft = sf->data

sefile = addfile("re_sft.nc", "w")
sftgif = sefile->sftgif

blc2 = new((/128, 256/), float, "No_FillValue")
blc2@longtime = "Mass Balance of CCSM"
blc2@units = "mm"
blc2@_FillValue = nah
blc2!0 = "lat"
blc2!1 = "lon"
blc2&lat  = new((/128/), double, "No_FillValue")
blc2&lon  = new((/256/), double, "No_FillValue")
blc2&lat = lat1
blc2&lon = lon1

; Read Mass Balance
do i = 0, 127
  do j = 0, 255
    if(blc1(i, j) .gt. 10)
      blc2(i, j) = 1
    end if
    if(blc1(i, j) .le. 10)
      blc2(i, j) = 0
    end if
    if(blc1(i, j) .le. -10)
      blc2(i, j) = -2
    end if
    if((sftgif(i, j) .eq. 1) .and. (blc1(i, j) .le. -10))
      blc2(i, j) = -1
    end if
  end do
end do

blc3 = where(sft .eq. 0, nah, blc2)
blc3@_FillValue = nah
copy_VarMeta(blc2, blc3)

system("rm -f blc_ccsm_final.nc")
out = addfile("blc_ccsm_final.nc", "c")
out->data = blc3
open = addfile("blc_ccsm_final.nc", "r")

end
