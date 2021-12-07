!-----------------------BEGIN NOTICE -- DO NOT EDIT-----------------------
! NASA GSFC Land Data Toolkit (LDT) V1.0
!-------------------------END NOTICE -- DO NOT EDIT-----------------------
! !MODULE: CYGNSSsm_obsMod
! 
! !DESCRIPTION: 
! This module handles the observation plugin for the 
! CYGNSS soil moisture retrievals
!
!
!   
! !REVISION HISTORY: 
!  21 Aug 2016: Sujay Kumar, Initial Specification
!  12 Feb 2018: Mahdi Navari, openwater proximity detection was added
! 			edited to read New version of the SPL3SMP_R14 (file structure
! 			 differs from the previous versions)
!  04 Jun 2019: Sujay Kumar, Updated to support SMAP L2 retrievals 
!  23 Jan 2021: Hyunglok Kim, UPdated to support CYGNSS Daily/Subdaily 
!               retrievals

module CYGNSSsm_obsMod
! !USES: 
  use ESMF
  use map_utils

  implicit none

  PRIVATE 
!-----------------------------------------------------------------------------
! !PUBLIC MEMBER FUNCTIONS:
!-----------------------------------------------------------------------------
  PUBLIC :: CYGNSSsm_obsinit
!-----------------------------------------------------------------------------
! !PUBLIC TYPES:
!-----------------------------------------------------------------------------
  PUBLIC :: CYGNSSsmobs
!EOP
  type, public :: cygnsssmobsdec

     character*100          :: odir
     character*20           :: data_designation
     real                   :: search_radius
     integer                :: mo
     real,    allocatable   :: smobs(:,:)
     integer                :: nc, nr
     type(proj_info)        :: proj
     integer, allocatable   :: n11(:)
  end type cygnsssmobsdec

  type(cygnsssmobsdec), allocatable::CYGNSSsmobs(:)

contains
  
!BOP
! 
! !ROUTINE: CYGNSSsm_obsInit
! \label{CYGNSSsm_obsInit}
! 
! !INTERFACE: 
  subroutine CYGNSSsm_obsinit()
! !USES: 
    use ESMF
    use LDT_coreMod,    only : LDT_rc, LDT_config
    use LDT_DAobsDataMod, only : LDT_DAobsData, LDT_initializeDAobsEntry
    use LDT_timeMgrMod, only : LDT_clock, LDT_calendar
    use LDT_logMod,     only : LDT_verify, LDT_logunit

    implicit none
! !ARGUMENTS: 

! 
! !DESCRIPTION: 
!  This subroutine initializes and sets up the data structures required
!  for reading CYGNSS soil moisture data. 
! 
!EOP
    integer            :: npts
    type(ESMF_TimeInterval) :: alarmInterval
    type(ESMF_Time)         :: alarmTime
    integer                 :: status, rc
    real                    :: gridDesci(20)
    integer                 :: n

    allocate(CYGNSSsmobs(LDT_rc%nnest))
    
    call ESMF_ConfigFindLabel(LDT_config, &
         'CYGNSS soil moisture observation directory:', rc=status)
    do n=1,LDT_rc%nnest
       call ESMF_ConfigGetAttribute(LDT_Config, CYGNSSsmobs(n)%odir, &
            rc=status)
       call LDT_verify(status, &
            'CYGNSS soil moisture observation directory: not defined')
    enddo

    call ESMF_ConfigFindLabel(LDT_config, &
         'CYGNSS soil moisture data designation:', rc=status)
    do n=1,LDT_rc%nnest
       call ESMF_ConfigGetAttribute(LDT_Config, &
            CYGNSSsmobs(n)%data_designation, &
            rc=status)
       call LDT_verify(status, &
            'CYGNSS soil moisture data designation: not defined')
    enddo

    call ESMF_ConfigFindLabel(LDT_config, &
         'CYGNSS search radius for openwater proximity detection:', rc=status)
    do n=1,LDT_rc%nnest
       call ESMF_ConfigGetAttribute(LDT_Config, CYGNSSsmobs(n)%search_radius, &
            rc=status)
       call LDT_verify(status, &
            'CYGNSS search radius for openwater proximity detection: not defined')
    enddo    
    
    do n=1,LDT_rc%nnest

       allocate(CYGNSSsmobs(n)%smobs(LDT_rc%lnc(n),LDT_rc%lnr(n)))

       CYGNSSsmobs(n)%smobs = -9999.0
       
       call LDT_initializeDAobsEntry(LDT_DAobsData(n)%soilmoist_obs, &
            "m3/m3",1,1)
       LDT_DAobsData(n)%soilmoist_obs%selectStats = 1       
        
       if(CYGNSSsmobs(n)%data_designation.eq."CYG_Daily".or.&
          CYGNSSsmobs(n)%data_designation.eq."CYG_SubDaily".or.&
          CYGNSSsmobs(n)%data_designation.eq."CYG_SMAP") then 
          CYGNSSsmobs(n)%nc = 964
          CYGNSSsmobs(n)%nr = 406
          gridDesci = 0 
          gridDesci(1) = 9
          gridDesci(2) = 964
          gridDesci(3) = 406
          gridDesci(9) = 4 !M36 grid
          gridDesci(20) = 64
          gridDesci(10) = 0.36 
          gridDesci(11) = 1 !for the global switch

       elseif(CYGNSSsmobs(n)%data_designation.eq."CYG_UCAR") then !should be updated later
          CYGNSSsmobs(n)%nc = 964
          CYGNSSsmobs(n)%nr = 406
          gridDesci = 0 
          gridDesci(1) = 9
          gridDesci(2) = 964
          gridDesci(3) = 406
          gridDesci(9) = 4 !M36 grid
          gridDesci(20) = 64
          gridDesci(10) = 0.36 
          gridDesci(11) = 1 !for the global switch

       endif
       allocate(CYGNSSsmobs(n)%n11(LDT_rc%lnc(n)*LDT_rc%lnr(n)))       
       call neighbor_interp_input (n, gridDesci,&
            CYGNSSsmobs(n)%n11)
    enddo
  end subroutine CYGNSSsm_obsinit
     
end module CYGNSSsm_obsMod
