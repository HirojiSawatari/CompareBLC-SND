load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

file1 = addfile("ccsm_sftlf.nc","w")

lat = file1->lat
lon = file1->lon
s = file1->sftlf

;printVarSummary(lat)

; change grid
lala = new((/192/),double,"No_FillValue")
lala = fspan(-90,90,192)

lolo = new((/288/),double,"No_FillValue")
lolo = fspan(0,360,288)

snd = new((/128,256/),float,"No_FillValue")
snd@longtime = "Land Area Fraction"
snd@units = "%"

snd!0 = "lat"
snd!1 = "lon"

snd&lat  = new((/128/),double,"No_FillValue")
snd&lon  = new((/256/),double,"No_FillValue")

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

system("rm -f re_sftlf.nc")
out = addfile("re_sftlf.nc","c")
out->data = snd
open = addfile("re_sftlf.nc","r")
;print(open)

end
