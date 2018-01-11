load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

blc = addfile("blc_out_final.nc", "w")
snd = addfile("snd_out_final.nc", "w")

b = blc->data
s = snd->data

numb = 0.
tot = 0.

bo = new((/128,256/), float, "No_FillValue")

; tibet(26~39N, 73~104E)
do i = 82, 91
  do j = 52, 74
    numb = numb + 1

    num1 = b(i, j) + s(i, j)
    bo(i, j) = num1 * num1

    tot = tot + bo(i, j)
  end do
end do

a = tot / numb
print(a)
asciiwrite("ncltmp_tibet.txt", a)

end
