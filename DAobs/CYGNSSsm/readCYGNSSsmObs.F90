!-----------------------BEGIN NOTICE -- DO NOT EDIT-----------------------
! NASA GSFC Land Data Toolkit (LDT) V1.0
!-------------------------END NOTICE -- DO NOT EDIT-----------------------
#include "LDT_misc.h"
!BOP
! 
! !ROUTINE: readCYGNSSsmObs
! \label{readCYGNSSsmObs}
! 
! !REVISION HISTORY: 
!  21 July 2010: Sujay Kumar, Initial Specification
!  12 Feb 2018: Mahdi Navari, openwater proximity detection was added
! 			edited to read New version of the SPL3SMP_R14 (file structure
! 			 differs from the previous versions) 
!  31 Aug 2018: Mahdi Navari, Edited to read SPL3SMP.005 & SPL3SMP_E.002
!  04 Jun 2019: Sujay Kumar, Updated to support SMAP L2 retrievals
!  21 Jan 2021: Hyunglok Kim, UPdated to support CYGNSS Daily/Subdaily
!               retrievals
! !INTERFACE: 
subroutine readCYGNSSsmObs(n)
! !USES:   
  use ESMF
  use LDT_coreMod
  use LDT_logMod
  use LDT_timeMgrMod
  use LDT_DAobsDataMod
  use CYGNSSsm_obsMod
  use map_utils

  implicit none
! !ARGUMENTS: 
  integer, intent(in) :: n
! 
! !DESCRIPTION: 
! 
! This subroutine provides the data reader for the ESACCI
! soil moisture retrieval product. 
!
!EOP

  real*8            :: timenow
  logical           :: alarmCheck
  logical           :: file_exists
  integer           :: c,r,i,j
  character*100     :: fname
  integer           :: mn_ind
  integer           :: yr, mo, da, hr, mn, ss
  integer           :: doy
  integer           :: ftn
  integer           :: ierr
  real              :: gmt
  character*8       :: yyyymmdd
  character*4       :: yyyy
  character*2       :: mm,dd,hh
  character*200     :: list_files
  character*100     :: cygnss_filename(10)
  real              :: smobs(LDT_rc%lnc(n)*LDT_rc%lnr(n))

!-----------------------------------------------------------------------
! It is assumed that CDF is computed using daily observations. 
!-----------------------------------------------------------------------
  CYGNSSsmobs(n)%smobs = LDT_rc%udef
  smobs= LDT_rc%udef
  if(CYGNSSsmobs(n)%data_designation.eq."CYG_SubDaily") then
       
     if(LDT_rc%ts.gt.3600) then 
        write(LDT_logunit,*)'[ERR] Please set the LDT timestep to 1hr or less'
        write(LDT_logunit,*)'[ERR] This is required for CYGNSS Subdaily data processing'
        call LDT_endrun()
     endif

     write(yyyymmdd,'(i4.4,2i2.2)') LDT_rc%yr, LDT_rc%mo, LDT_rc%da
     write(yyyy,'(i4.4)') LDT_rc%yr
     write(mm,'(i2.2)') LDT_rc%mo
     write(dd,'(i2.2)') LDT_rc%da
     write(hh,'(i2.2)') LDT_rc%hr
     
     list_files = 'ls '//trim(CYGNSSsmobs(n)%odir)//&
          '/'//trim(yyyy)//'.'//trim(mm)//'.'//dd//&
          '/CYG_SubDaily_*'//trim(yyyymmdd)//'T'//trim(hh)&
          //"*.h5 > CYGNSS_filelist.dat"
     
     call system(trim(list_files))

     i = 1
     ftn = LDT_getNextUnitNumber()
    
     open(ftn,file="./CYGNSS_filelist.dat",&
          status='old',iostat=ierr)
     
     do while(ierr.eq.0) 
        read(ftn,'(a)',iostat=ierr) fname
        if(ierr.ne.0) then 
           exit
        endif
        
        mn_ind = index(fname,trim(yyyymmdd)//'T'//trim(hh))+11        
        read(fname(mn_ind:mn_ind+1),'(i2.2)') mn
        ss=0
        call LDT_tick(timenow,doy,gmt,LDT_rc%yr, LDT_rc%mo, LDT_rc%da, &
                LDT_rc%hr, mn, ss, 0.0)
        
        cygnss_filename(i) = fname
        
        write(LDT_logunit,*) '[INFO] reading ',trim(cygnss_filename(i))
        
        call read_CYGNSS_SubDailysm_data(n,cygnss_filename(i),&
             CYGNSSsmobs(n)%smobs,timenow)
        
        i = i+1
    enddo
     call LDT_releaseUnitNumber(ftn)

  elseif(CYGNSSsmobs(n)%data_designation.eq."CYG_SMAP") then
       
     if(LDT_rc%ts.gt.3600) then 
        write(LDT_logunit,*)'[ERR] Please set the LDT timestep to 1hr or less'
        write(LDT_logunit,*)'[ERR] This is required for CYGNSS Subdaily data processing'
        call LDT_endrun()
     endif

     write(yyyymmdd,'(i4.4,2i2.2)') LDT_rc%yr, LDT_rc%mo, LDT_rc%da
     write(yyyy,'(i4.4)') LDT_rc%yr
     write(mm,'(i2.2)') LDT_rc%mo
     write(dd,'(i2.2)') LDT_rc%da
     write(hh,'(i2.2)') LDT_rc%hr
     
     list_files = 'ls '//trim(CYGNSSsmobs(n)%odir)//&
          '/'//trim(yyyy)//'.'//trim(mm)//'.'//dd//&
          '/*_*'//trim(yyyymmdd)//'T'//trim(hh)&
          //"*.h5 > CYGNSS_SMAP_filelist.dat"
     
     call system(trim(list_files))

     i = 1
     ftn = LDT_getNextUnitNumber()
    
     open(ftn,file="./CYGNSS_SMAP_filelist.dat",&
          status='old',iostat=ierr)
     
     do while(ierr.eq.0) 
        read(ftn,'(a)',iostat=ierr) fname
        if(ierr.ne.0) then 
           exit
        endif
        
        mn_ind = index(fname,trim(yyyymmdd)//'T'//trim(hh))+11        
        read(fname(mn_ind:mn_ind+1),'(i2.2)') mn
        ss=0
        call LDT_tick(timenow,doy,gmt,LDT_rc%yr, LDT_rc%mo, LDT_rc%da, &
                LDT_rc%hr, mn, ss, 0.0)
        
        cygnss_filename(i) = fname
        
        write(LDT_logunit,*) '[INFO] reading ',trim(cygnss_filename(i))
        
        call read_CYGNSS_SubDailysm_data(n,cygnss_filename(i),&
             CYGNSSsmobs(n)%smobs,timenow)
        
        i = i+1
    enddo
     call LDT_releaseUnitNumber(ftn)

  elseif(CYGNSSsmobs(n)%data_designation.eq."CYG_Daily") then
  
     call create_CYGNSSsm_filename(CYGNSSsmobs(n)%odir, &
          CYGNSSsmobs(n)%data_designation,&
          LDT_rc%yr, LDT_rc%mo, LDT_rc%da, fname)
     inquire(file=trim(fname),exist=file_exists)

     if(file_exists) then
        
        write(LDT_logunit,*) '[INFO] Reading ..',trim(fname)
        call read_CYGNSS_Dailysm_data(n, fname, smobs)
        write(LDT_logunit,*) '[INFO] Finished reading ',trim(fname)       
        
        do r=1,LDT_rc%lnr(n)
           do c=1,LDT_rc%lnc(n)
              if(smobs(c+(r-1)*LDT_rc%lnc(n)).ne.-9999.0) then 
                 CYGNSSsmobs(n)%smobs(c,r) = smobs(c+(r-1)*LDT_rc%lnc(n))             
              endif
           enddo
        enddo        
        
     endif
  
  endif
  
  call LDT_logSingleDAobs(n,LDT_DAobsData(n)%soilmoist_obs,&
       CYGNSSsmobs(n)%smobs,vlevel=1)

end subroutine readCYGNSSsmObs

!BOP
! 
! !ROUTINE: read_CYGNSS_SubDailysm_data
! \label{read_CYGNSS_SubDailysm_data}
!
! !INTERFACE:
subroutine read_CYGNSS_SubDailysm_data(n, fname, smobs_inp, time)
! 
! !USES:   

  use LDT_coreMod
  use LDT_logMod
  use LDT_timeMgrMod
  use CYGNSSsm_obsMod
#if (defined USE_HDF5) 
  use hdf5
#endif

  implicit none
!
! !INPUT PARAMETERS: 
! 
  integer                  :: n
  character (len=*)        :: fname
  real                     :: smobs_inp(LDT_rc%lnc(n),LDT_rc%lnr(n))
  real*8                   :: time

! !OUTPUT PARAMETERS:
!
!
! !DESCRIPTION: 
!
!
!EOP

#if (defined USE_HDF5)

  character*100,    parameter    :: sm_gr_name = "Soil_Moisture_Retrieval_Data"
  character*100,    parameter    :: sm_field_name = "soil_moisture"

  integer(hsize_t), dimension(1) :: dims
  integer(hsize_t), dimension(1) :: maxdims
  integer(hid_t)                 :: file_id
  integer(hid_t)                 :: dspace_id
  integer(hid_t)                 :: row_id, col_id
  integer(hid_t)                 :: sm_gr_id,sm_field_id
  real,             allocatable  :: sm_field(:)
  integer,          allocatable  :: ease_row(:)
  integer,          allocatable  :: ease_col(:)
  integer                        :: c,r,t
  logical*1                      :: sm_data_b(CYGNSSsmobs(n)%nc*CYGNSSsmobs(n)%nr)
  logical*1                      :: smobs_b_ip(LDT_rc%lnc(n)*LDT_rc%lnr(n))
  real                           :: sm_data(CYGNSSsmobs(n)%nc*CYGNSSsmobs(n)%nr)
  real                           :: smobs_ip(LDT_rc%lnc(n)*LDT_rc%lnr(n))

  integer                        :: status,ios,iret

  call h5open_f(status)
  call LDT_verify(status, 'Error opening HDF fortran interface')
  
  call h5fopen_f(trim(fname),H5F_ACC_RDONLY_F, file_id, status) 
  call LDT_verify(status, 'Error opening CYGNSS or SMAP file ')
  
  call h5gopen_f(file_id,sm_gr_name,sm_gr_id, status)
  call LDT_verify(status, 'Error opening SM group in CYGNSS or SMAP file')
  
  call h5dopen_f(sm_gr_id,sm_field_name,sm_field_id, status)
  call LDT_verify(status, 'Error opening SM field in CYGNSS or SMAP Subdaily file')

  call h5dopen_f(sm_gr_id,"EASE_row_index",row_id, status)
  call LDT_verify(status, 'Error opening row index field in CYGNSS or SMAP file')

  call h5dopen_f(sm_gr_id,"EASE_column_index",col_id, status)
  call LDT_verify(status, 'Error opening column index field in CYGNSS or SMAP file')
  
  call h5dget_space_f(sm_field_id, dspace_id, status)
  call LDT_verify(status, 'Error in h5dget_space_f: readCYGNSS_Subdaily Obs')
! Size of the arrays
! This routine returns -1 on failure, rank on success. 
  call h5sget_simple_extent_dims_f(dspace_id, dims, maxdims, status) 
  if(status.eq.-1) then 
     call LDT_verify(status, 'Error in h5sget_simple_extent_dims_f: readCYGNSS Subdaily Obs')
  endif
  
  allocate(sm_field(maxdims(1)))
  allocate(ease_row(maxdims(1)))
  allocate(ease_col(maxdims(1)))

  call h5dread_f(row_id, H5T_NATIVE_INTEGER,ease_row,dims,status)
  call LDT_verify(status, 'Error extracting row index from CYGNSS Subdaily file')

  call h5dread_f(col_id, H5T_NATIVE_INTEGER,ease_col,dims,status)
  call LDT_verify(status, 'Error extracting col index from CYGNSS Subdaily file')
  
  call h5dread_f(sm_field_id, H5T_NATIVE_REAL,sm_field,dims,status)
  call LDT_verify(status, 'Error extracting SM field from CYGNSS Subdaily file')

  call h5dclose_f(row_id,status)
  call LDT_verify(status,'Error in H5DCLOSE call')

  call h5dclose_f(col_id,status)
  call LDT_verify(status,'Error in H5DCLOSE call')

  call h5dclose_f(sm_field_id,status)
  call LDT_verify(status,'Error in H5DCLOSE call')
  
  call h5gclose_f(sm_gr_id,status)
  call LDT_verify(status,'Error in H5GCLOSE call')
    
  call h5fclose_f(file_id,status)
  call LDT_verify(status,'Error in H5FCLOSE call')
  
  call h5close_f(status)
  call LDT_verify(status,'Error in H5CLOSE call')

  sm_data = LDT_rc%udef
  sm_data_b = .false. 

!grid the data in EASE projection
  do t=1,maxdims(1)
     if(ease_col(t).gt.0.and.ease_row(t).gt.0) then 
        sm_data(ease_col(t) + &
             (ease_row(t)-1)*CYGNSSsmobs(n)%nc) = sm_field(t) 
        if(sm_field(t).ne.-9999.0) then 
           sm_data_b(ease_col(t) + &
                (ease_row(t)-1)*CYGNSSsmobs(n)%nc) = .true. 
        endif
     endif
  enddo
  
  t = 1
!--------------------------------------------------------------------------
! Interpolate to the LDT running domain
!-------------------------------------------------------------------------- 
  call neighbor_interp(LDT_rc%gridDesc, sm_data_b, sm_data, &
       smobs_b_ip, smobs_ip, &
       CYGNSSsmobs(n)%nc*CYGNSSsmobs(n)%nr,&
       LDT_rc%lnc(n)*LDT_rc%lnr(n),&
       LDT_domain(n)%lat, LDT_domain(n)%lon,&
       CYGNSSsmobs(n)%n11,LDT_rc%udef, iret)

  deallocate(sm_field)
  deallocate(ease_row)
  deallocate(ease_col)

!overwrite the input data 
  do r=1,LDT_rc%lnr(n)
     do c=1,LDT_rc%lnc(n)
        if(smobs_ip(c+(r-1)*LDT_rc%lnc(n)).ne.-9999.0) then 
           smobs_inp(c,r) = & 
                smobs_ip(c+(r-1)*LDT_rc%lnc(n))

!           CYGNSSsmobs(n)%smtime(c,r) = & 
!                time
        endif
     enddo
  enddo

#endif

end subroutine read_CYGNSS_SubDailysm_data


!BOP
! 
! !ROUTINE: read_CYGNSS_Dailysmdata
! \label(read_CYGNSS_data)
!
! !INTERFACE:
subroutine read_CYGNSS_Dailysm_data(n, fname, smobs_ip)
! 
! !USES:   
  use LDT_coreMod
  use LDT_logMod
  use map_utils
  use CYGNSSsm_obsMod, only : CYGNSSsmobs
  use LDT_paramDataMod, only : LDT_LSMparam_struc
#if (defined USE_HDF5) 
  use hdf5
#endif

  implicit none
!
! !INPUT PARAMETERS: 
! 
  integer                       :: n 
  character (len=*)             :: fname
  real                          :: smobs_ip(LDT_rc%lnc(n)*LDT_rc%lnr(n))


! !OUTPUT PARAMETERS:
!
! !DESCRIPTION: 
! 
!  The arguments are: 
!  \begin{description}
!  \item[n]            index of the nest
!  \item[fname]        name of the SMOS NESDIS file
!  \item[smobs\_ip]    soil moisture data processed to the LDT domain
! \end{description}
!
! !FILES USED:
!
! !REVISION HISTORY: 
! 
!EOP
#if (defined USE_HDF5)

  character*100,    parameter    :: sm_gr_name = "Soil_Moisture_Retrieval_Data_Daily"
  character*100,    parameter    :: sm_field_name = "soil_moisture"

  integer(hsize_t), allocatable  :: dims(:)
  integer(hsize_t), dimension(2) :: dimsm
  integer(hsize_t), dimension(2) :: count_file
  integer(hsize_t), dimension(2) :: count_mem
  integer(hid_t)                 :: memspace
  integer(hid_t)                 :: dataspace
  integer                        :: memrank = 2
  integer(hsize_t), dimension(2) :: offset_mem = (/0,0/)
  integer(hsize_t), dimension(2) :: offset_file = (/0,0/)
  integer(hid_t)                 :: file_id, sm_gr_id,sm_field_id
  real,             allocatable  :: sm_field(:,:)
  real,             allocatable  :: sm_field_Daily(:,:)
  integer                        :: c,r,t
  logical*1                      :: sm_data_b(CYGNSSsmobs(n)%nc*CYGNSSsmobs(n)%nr)
  logical*1                      :: smobs_b_ip(LDT_rc%lnc(n)*LDT_rc%lnr(n))
  real                           :: sm_data(CYGNSSsmobs(n)%nc*CYGNSSsmobs(n)%nr)
  integer                        :: search_rad
  integer                        :: ix, jx, c_s, c_e, r_s,r_e
  integer                        :: status
  
  dimsm      = (/CYGNSSsmobs(n)%nc, CYGNSSsmobs(n)%nr/)
  count_file = (/CYGNSSsmobs(n)%nc, CYGNSSsmobs(n)%nr/)
  count_mem  = (/CYGNSSsmobs(n)%nc, CYGNSSsmobs(n)%nr/)
  
  allocate(sm_field(CYGNSSsmobs(n)%nc, CYGNSSsmobs(n)%nr))
  allocate(sm_field_Daily(CYGNSSsmobs(n)%nc, CYGNSSsmobs(n)%nr))
  allocate(dims(2))

  dims(1) = CYGNSSsmobs(n)%nc
  dims(2) = CYGNSSsmobs(n)%nr

     call h5open_f(status)
     call LDT_verify(status, 'Error opening HDF fortran interface')
     
     call h5fopen_f(trim(fname),H5F_ACC_RDONLY_F, file_id, status) 
     call LDT_verify(status, 'Error opening NASASMAP file ')     

!Read the daily CYGNSS data     
     call h5gopen_f(file_id,sm_gr_name,sm_gr_id, status)
     call LDT_verify(status, 'Error opening SM group in CYGNSS file')

     call h5dopen_f(sm_gr_id,sm_field_name,sm_field_id, status)
     call LDT_verify(status, 'Error opening SM field in CYGNSS file')
     
     call h5dget_space_f(sm_field_id, dataspace, status)
     call LDT_verify(status, 'Error in h5dget_space_f: readCYGNSSObs')
     
     call h5sselect_hyperslab_f(dataspace, H5S_SELECT_SET_F, &
          start=offset_file, count=count_file, hdferr=status)
     call LDT_verify(status, 'Error setting hyperslab dataspace in readCYGNSSObs')
     
     call h5screate_simple_f(memrank,dimsm, memspace, status)
     call LDT_verify(status, 'Error in h5create_simple_f; readCYGNSSObs')
     
     call h5sselect_hyperslab_f(memspace, H5S_SELECT_SET_F, &
          start=offset_mem, count=count_mem, hdferr=status)
     call LDT_verify(status, 'Error in h5sselect_hyperslab_f: readCYGNSSObs')
     
     call h5dread_f(sm_field_id, H5T_NATIVE_REAL,sm_field_Daily,dims,status, &
          memspace, dataspace)
     call LDT_verify(status, 'Error extracting SM field from CYGNSS file')

     call h5dclose_f(sm_field_id,status)
     call LDT_verify(status,'Error in H5DCLOSE call')

     call h5gclose_f(sm_gr_id,status)
     call LDT_verify(status,'Error in H5GCLOSE call')
     
     call h5fclose_f(file_id,status)
     call LDT_verify(status,'Error in H5FCLOSE call')
     
     call h5close_f(status)
     call LDT_verify(status,'Error in H5CLOSE call')
     
     sm_field = LDT_rc%udef !we may not need this loops
     do r=1,CYGNSSsmobs(n)%nr
        do c=1,CYGNSSsmobs(n)%nc
           if(sm_field_Daily(c,r).ne.LDT_rc%udef) then              
              sm_field(c,r) = sm_field_Daily(c,r)
           endif
        enddo
     enddo

  sm_data_b = .false. 
  t = 1

  do r=1,CYGNSSsmobs(n)%nr
     do c=1,CYGNSSsmobs(n)%nc        
!may need this for global applications? TBD -SVK
!        sm_data(t) = sm_field(NASASMAPsmobs(n)%nc-c+1,r)
        sm_data(t) = sm_field(c,r)
!        sm_data(t) = sm_field(c,NASASMAPsmobs(n)%nr-r+1)
        if(sm_data(t).ne.-9999.0) then 
           sm_data_b(t) = .true.
        endif
        t = t+1
     enddo
  enddo

!--------------------------------------------------------------------------
! Interpolate to the LDT running domain
!-------------------------------------------------------------------------- 

  call neighbor_interp(LDT_rc%gridDesc(n,:),&
       sm_data_b, sm_data, smobs_b_ip, smobs_ip, &
       CYGNSSsmobs(n)%nc*CYGNSSsmobs(n)%nr, &
       LDT_rc%lnc(n)*LDT_rc%lnr(n), &
       LDT_domain(n)%lat, LDT_domain(n)%lon,&
       CYGNSSsmobs(n)%n11,&
       LDT_rc%udef, status)   

  deallocate(sm_field)
  deallocate(dims)
  
  !------------------------------------------------------------------------
  !  Remove pixel close to open water
  !------------------------------------------------------------------------
  do r = 1, LDT_rc%lnr(n)
     do c = 1, LDT_rc%lnc(n)
        if (smobs_ip(c+(r-1)*LDT_rc%lnc(n)) .ne. LDT_rc%udef) then 
           search_rad = nint(CYGNSSsmobs(n)%search_radius)
           
           c_s = max(1,c-search_rad)
           c_e = min(LDT_rc%lnc(n),c+search_rad)
           
           r_s = max(1,r-search_rad)
           r_e = min(LDT_rc%lnr(n),r+search_rad)
           
           do ix=c_s,c_e
              do jx=r_s,r_e
                 if( LDT_LSMparam_struc(n)%landmask%value(ix,jx,1) .eq. 0 ) then
                    smobs_ip(c+(r-1)*LDT_rc%lnc(n)) = LDT_rc%udef
                 end if
              enddo
           enddo
        endif
     enddo
  enddo

#endif

end subroutine read_CYGNSS_Dailysm_data

!BOP
! !ROUTINE: create_CYGNSSsm_filename
! \label{create_CYGNSSsm_filename}
! 
! !INTERFACE: 
subroutine create_CYGNSSsm_filename(ndir, designation,yr, mo,da, filename)
! !USES:

  implicit none
! !ARGUMENTS: 
  character(len=*)  :: filename
  character(len=*)  :: designation
  integer           :: yr, mo, da
  character(len=*) :: ndir
! 
! !DESCRIPTION: 
!  This subroutine creates the timestamped NASASMAP filename 
! 
!  The arguments are: 
!  \begin{description}
!  \item[ndir] name of the CYGNSS soil moisture directory
!  \item[yr]  current year
!  \item[mo]  current month
!  \item[da]  current day
!  \item[filename] Generated NASASMAP filename
! \end{description}
!EOP

  character (len=4) :: fyr
  character (len=2) :: fmo,fda
  
  write(unit=fyr, fmt='(i4.4)') yr
  write(unit=fmo, fmt='(i2.2)') mo
  write(unit=fda, fmt='(i2.2)') da
 
  filename = trim(ndir)//'/'//trim(fyr)//'.'//trim(fmo)//'.'//&
             trim(fda)//'/CYG_Daily_'&
             //trim(fyr)//trim(fmo)//trim(fda)//&
             '.h5'
end subroutine create_CYGNSSsm_filename
