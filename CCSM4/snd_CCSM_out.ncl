load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

file1 = addfile("snd_LImon_CCSM4_lgm_r1i1p1_180001-190012.nc","w")

lat = file1->lat
lon = file1->lon
time = file1->time
s = file1->snd

;printVarSummary(lat)

; change grid
lala = new((/192/),double,"No_FillValue")
lala = fspan(-90,90,192)

lolo = new((/288/),double,"No_FillValue")
lolo = fspan(0,360,288)

snd = new((/1212,128,256/),float,"No_FillValue")
snd@longtime = "Snow Depth of CCSM"
snd@units = "m"

snd!0 = "time"
snd!1 = "lat"
snd!2 = "lon"

snd&time = new((/1212/),double,"No_FillValue")
snd&lat  = new((/128/),double,"No_FillValue")
snd&lon  = new((/256/),double,"No_FillValue")

snd&time = fspan(0,1211,1212)
snd&time@long_name = "time"

snd&lat = fspan(-90,90,128)
NLATG = 128           ; appropriate global value
snd&lat@units = "degrees_north"
snd&lat@long_name = "lattitude"

snd&lon = fspan(0,360,256)
snd&lon@units = "degrees_east"
snd&lon@long_name = "lontitude"

opt = True
opt@NLATo = NLATG
snd = area_conserve_remap_Wrap (lolo, lala, s, snd&lon, snd&lat, opt)  ; (ntim,128,256)
;printVarSummary(snd)

system("rm -f snd_regrid_ccsm.nc")
out = addfile("snd_regrid_ccsm.nc","c")
out->data = snd
open = addfile("snd_regrid_ccsm.nc","r")
;print(open)

end
