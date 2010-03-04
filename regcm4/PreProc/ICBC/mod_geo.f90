      module mod_geo

      use mod_domain, only : jx , iy , kz

      implicit none

      real , dimension(jx,iy) :: coriol , dlat , dlon , msfx , snowcv , &
                               & topogm , toposdgm , xlandu , xlat ,    &
                               & xlon
      real , dimension(kz) :: dsigma , sigma2
      real , dimension(kz+1) :: sigmaf
      real :: delx , grdfac
      real :: truelath , truelatl
      character(6) :: lgtype

      end module mod_geo