      subroutine height_o(hp,h,t,pstar,ht,sig,ptop,im,jm,km,p,kp)
 
!  HEIGHT DETERMINES THE HEIGHT OF PRESSURE LEVELS.
!     ON INPUT:
!        H AND T ARE HEIGHT AND TEMPERATURE ON SIGMA, RESPECTIVELY.
!        PSTAR = SURFACE PRESSURE - MODEL TOP PRESSURE.
!        SIG = SIGMA LEVELS.
!        P = PRESSURE LEVELS DESIRED.
!     ON OUTPUT:
!        ALL FIELDS EXCEPT H ARE UNCHANGED.
!        H HAS HEIGHT FIELDS AT KP PRESSURE LEVELS.
!
!  FOR UPWARD EXTRAPOLATION, T IS CONSIDERED TO HAVE 0 VERITCAL DERIV.
!  FOR DOWNWARD EXTRAPOLATION, T HAS LAPSE RATE OF TLAPSE (K/KM)
!     AND EXTRAPOLATION IS DONE FROM THE LOWEST SIGMA LEVEL ABOVE
!     THE BOUNDARY LAYER (TOP ARBITRARILY TAKEN AT SIGMA = BLTOP).
!     EQUATION USED IS EXACT SOLUTION TO HYDROSTATIC RELATION,
!     GOTTEN FROM R. ERRICO (ALSO USED IN SLPRES ROUTINE):
!      Z = Z0 - (T0/TLAPSE) * (1.-EXP(-R*TLAPSE*LN(P/P0)/G))
!
      use mod_constants , only : rgti , rgas , lrate
      implicit none
!
! Dummy arguments
!
      integer :: im , jm , km , kp
      real :: ptop
      real , dimension(im,jm,km) :: h , t
      real , dimension(im,jm,kp) :: hp
      real , dimension(im,jm) :: ht , pstar
      real , dimension(kp) :: p
      real , dimension(km) :: sig
      intent (in) h , ht , im , jm , km , kp , p , pstar , ptop , sig , &
                & t
      intent (out) hp
!
! Local variables
!
      real :: psfc , temp , wb , wt
      integer :: i , j , k , kb , kbc , kt , n
      real , dimension(100) :: psig
      real, parameter :: bltop = 0.96
!
      do k = 1 , km
        if ( sig(k)<bltop ) kbc = k
      end do
!     PRINT *,'FIRST SIGMA LEVEL ABOVE BNDY LAYER:', SIG(KBC)
!
      do j = 1 , jm
        do i = 1 , im
          do k = 1 , km
            psig(k) = sig(k)*(pstar(i,j)-ptop) + ptop
          end do
          psfc = pstar(i,j)
          do n = 1 , kp
            kt = 1
            do k = 1 , km
              if ( psig(k)<p(n) ) kt = k
            end do
            kb = kt + 1
            if ( p(n)<=psig(1) ) then
              temp = t(i,j,1)
              hp(i,j,n) = h(i,j,1) + rgas*temp*log(psig(1)/p(n))*rgti
            else if ( (p(n)>psig(1)) .and. (p(n)<psig(km)) ) then
              wt = log(psig(kb)/p(n))/log(psig(kb)/psig(kt))
              wb = log(p(n)/psig(kt))/log(psig(kb)/psig(kt))
              temp = wt*t(i,j,kt) + wb*t(i,j,kb)
              temp = (temp+t(i,j,kb))/2.
              hp(i,j,n) = h(i,j,kb) + rgas*temp*log(psig(kb)/p(n))*rgti
            else if ( (p(n)>=psig(km)) .and. (p(n)<=psfc) ) then
              temp = t(i,j,km)
              hp(i,j,n) = ht(i,j) + rgas*temp*log(psfc/p(n))*rgti
            else if ( p(n)>psfc ) then
              temp = t(i,j,kbc) + lrate*(h(i,j,kbc)-ht(i,j))
              hp(i,j,n) = ht(i,j) + (temp/lrate)                        &
                        & *(1.-exp(+rgas*lrate*log(p(n)/psfc)*rgti))
!
            else
            end if
          end do
        end do
      end do
      end subroutine height_o