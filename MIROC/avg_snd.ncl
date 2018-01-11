load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Grade -2:Null; -1:trend<0 and ice sheet=1&snow depth=0; 0:snow depth>0 and trend=[-10^-2, 10^-2](m/yr);

begin 

file1 = addfile("snd_regrid_ccsm.nc", "w")

lat1 = file1->lat
lon1 = file1->lon
tas1 = file1->data

nah = tas1@_FillValue
print(nah)

sf = addfile("re_sftlf.nc", "r")
sft = sf->data

sefile = addfile("re_sft.nc", "w")
sftgif = sefile->sftgif

snd1 = new((/128, 256/), float, "No_FillValue")
snd1@longtime = "Snow Depth of CCSM"
snd1@units = "m"
snd1!0 = "lat"
snd1!1 = "lon"
snd1&lat  = new((/128/), double, "No_FillValue")
snd1&lon  = new((/256/), double, "No_FillValue")
snd1&lat = lat1
snd1&lon = lon1

; calculate the average of Snow Depth
do i = 0, 127
  do j = 0, 255
    if(.not. ismissing(tas1(0, i, j)))
      if(tas1(0, i, j) .lt. 10)
        sdata = avg(tas1(:, i, j))
        ; maximum of snd
        sval = 2.4
        if(sdata .ge. sval)
          snd1(i, j) = 1
        end if
        if(sdata .lt. sval)
          snd1(i, j) = -1
        end if
        if(sdata .eq. 0)
          snd1(i, j) = -2
        end if
      end if
    end if
  end do
end do

; calculate the trend
;do i = 0, 127
;  do j = 0, 255
;    ; slope
;    dtrline = dtrend(tas1(:, i, j), True)
;    dtr = dtrline@slope
;    ; greater than 0, is ice-sheet
;    ;val = 10^(-6)
;    ;if(dtr .gt. val)
;    ;  snd1(i, j) = 1
;    ;end if
;    ;if(dtr .le. val)
;    ;  snd1(i, j) = 0
;    ;end if
;    snd1(i, j) = dtr
;  end do
;end do

system("rm -f snd_ccsm.nc")
out1 = addfile("snd_ccsm.nc", "c")
out1->data = snd1
open1 = addfile("snd_ccsm.nc", "r")

; trend_manken

snd2 = new((/128, 256/), float, "No_FillValue")
snd2@longtime = "Snow Depth of CCSM"
snd2@units = "m"
snd2@_FillValue = nah
snd2!0 = "lat"
snd2!1 = "lon"
snd2&lat  = new((/128/), double, "No_FillValue")
snd2&lon  = new((/256/), double, "No_FillValue")
snd2&lat = lat1
snd2&lon = lon1

; calculate the trend
opt = True
;opt@return_trend = False
do i = 0, 127
  do j = 0, 255
    ; slope
    if(.not. ismissing(tas1(0, i, j)))
      if(tas1(0, i, j) .lt. 10)    
        tm2 = trend_manken(tas1(:, i, j), opt, 0)
        tm = tm2(1)
        ; greater than 0, is ice-sheet
        val1 = 10^(-2) / 12
        val2 = 0 - val1
        if(tm .gt. val1)
          snd2(i, j) = 1
        end if
        if(tm .le. val1)
          snd2(i, j) = 0
        end if
        if(tm .le. val2)
          snd2(i, j) = -1
        end if
      end if
    end if
  end do
end do

system("rm -f snd_ccsm_tm.nc")
out2 = addfile("snd_ccsm_tm.nc", "c")
out2->data = snd2
open2 = addfile("snd_ccsm_tm.nc", "r")

do i = 0, 127
  do j = 0, 255
    if(snd1(i, j) .eq. 1)
      snd2(i, j) = 1
    end if
    if(snd1(i, j) .eq. -2)
      snd2(i, j) = -2
    end if
    if((sftgif(i, j) .eq. 1) .and. (snd1(i, j) .eq. -2))
      snd2(i, j) = -1
    end if
  end do
end do

snd3 = where(sft .eq. 0, nah, snd2)
snd3@_FillValue = nah
copy_VarMeta(snd2, snd3)

system("rm -f snd_ccsm_final.nc")
out3 = addfile("snd_ccsm_final.nc", "c")
out3->data = snd3
open3 = addfile("snd_ccsm_final.nc", "r")

end
