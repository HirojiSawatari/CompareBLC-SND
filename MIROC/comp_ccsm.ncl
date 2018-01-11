load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

blc = addfile("blc_ccsm_final.nc", "w")
snd = addfile("snd_ccsm_final.nc", "w")

b = blc->data
s = snd->data

numb = 0.
tot = 0.

bo = new((/128,256/), float, "No_FillValue")

; num = (b - s)^2
do i = 0, 127
  do j = 0, 255
    if(.not. ismissing(b(i, j)))
      numb = numb + 1

      num1 = b(i, j) + s(i, j)
      bo(i, j) = num1 * num1

      tot = tot + bo(i, j)
    end if
  end do
end do

; b - s
;do i = 0, 127
;  do j = 0, 255
;    if(.not. ismissing(b(i, j)))
;      ; b>0 s>0
;      numb = numb + 1
;      if((b(i, j) .eq. 1) .and. ((s(i, j) .eq. 0) .or. (s(i, j) .eq. 1)))
;        bo(i, j) = 0
;      end if
;
;      ; b<=0 s<=0
;      if((b(i, j) .eq. -1) .and. ((s(i, j) .eq. -2) .or. (s(i, j) .eq. -1)))
;        bo(i, j) = 0
;      end if
;
;      ; b>0 s<=0
;      if((b(i, j) .eq. 1) .and. ((s(i, j) .eq. -2) .or. (s(i, j) .eq. -1)))
;        bo(i, j) = 1
;      end if
;
;      ; b<=0 s>0
;      if((b(i, j) .eq. -1) .and. ((s(i, j) .eq. 0) .or. (s(i, j) .eq. 1)))
;        ; bo(i, j) = -1
;        bo(i, j) = 1
;      end if
;
;      tot = tot + bo(i, j)
;    end if
;  end do
;end do


; blc - snd
;do i = 0, 127
;  do j = 0, 255
;    ; b>0 s>0
;    if((b(i, j) .gt. 0) .and. (s(i, j) .gt. 0))
;      bo(i, j) = 0
;    end if
;
;    ; b<=0 s<=0
;    if((b(i, j) .le. 0) .and. (s(i, j) .le. 0))
;      bo(i, j) = 0
;    end if
;
;    ; b>0 s<=0
;    if((b(i, j) .gt. 0) .and. (s(i, j) .le. 0))
;      bo(i, j) = 1
;    end if
;
;    ; b<=0 s>0
;    if((b(i, j) .le. 0) .and. (s(i, j) .gt. 0))
;      bo(i, j) = -1
;    end if
;  end do
;end do

a = tot / numb
print(a)
asciiwrite("ncltmp.txt", a)

end
