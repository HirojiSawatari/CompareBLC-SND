load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;; Read data from raw files
file1=addfile("tas_Amon_FGOALS-g2_lgm_r1i1p1_055001-064912.nc","r")

lat=file1->lat
lon=file1->lon
time=file1->time
tas=file1->tas

new_monthly= new((/12,dimsizes(lat),dimsizes(lon)/),float,"No_FillValue")
i=0
do while (i .lt. 12)
	monthly=tas(i:dimsizes(time)-1:12,:,:)
	avg_monthly=dim_avg_n(monthly,0)
	new_monthly(i,:,:)=avg_monthly(:,:)-273.15
i=i+1
end do

;; Assign the dimensions
new_monthly!0="time"
new_monthly!1="lat"
new_monthly!2="lon"

;; Create new variables for each dimensions of new_monthly
new_monthly&time = new((/12/),float,"No_FillValue")
new_monthly&lat  = new((/dimsizes(lat)/),double,"No_FillValue")
new_monthly&lon  = new((/dimsizes(lon)/),double,"No_FillValue")

;; Assign the first dimension time
;; 1-12
new_monthly&time=ispan(1,12,1)
;print(new_monthly&time)

;; Assign the second and third dimensions
new_monthly&lat=file1->lat  
new_monthly&lon=file1->lon

;; Check the assignment
;print(new_monthly&lat)

;; Name the variable and unit
new_monthly@long_name="monthly average temperature"
new_monthly@units="C"


;; Create a new .nc to save new_monthly file
system("rm -f monthlydata_CNRM.nc")
out=addfile("monthlydata_CNRM.nc","c")

;; Assign the value to out
out->data_monthly = new_monthly
out->time = ispan(1,12,1)
out->lat  = lat
out->lon  = lon

;; Check if the output is the same as expected
test_data1 = new_monthly(:,2,2)

;; Write AscII files
system("rm -f monthlydata_CNRM.txt")
asciiwrite("monthlydata_CNRM.txt",out->data_monthly)

; change grid
lala = new((/60/),double,"No_FillValue")
lala = fspan(-90,90,60)

lolo = new((/128/),double,"No_FillValue")
lolo = fspan(0,360,128)

;; The following is to regridding to 12*128*256
LON  = fspan(0,360, 256)
LON@units = "degrees_east"
LON!0="lon"
NLATG= 128           ; appropriate global value
LAT = fspan(-90,90,128)
LAT@units = "degrees_north"
LAT!0="lat"

opt = True
opt@NLATo = NLATG              
po  = area_conserve_remap_Wrap (lolo, lala, new_monthly, LON, LAT, opt)  ; (ntim,128,256)

test_data3 = po(:,2,2)
;print(test_data3)
test_data4 = po(:,1,1)
;print(test_data4)

;; Write ASCII Files for regridded data
system("rm -f re_monthlydata.txt")
asciiwrite("re_monthlydata.txt",po)

end

