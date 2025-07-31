
dmesg | grep -i "IOMMU: DETECTED" 

efibootmgr -v | grep -Ei 'grub|ubuntu|systemd'

lspci -nnk | grep -Ei 'VGA|Audio device'

lscpu | grep -E 'AMD|INTEL'

systemctl enable libvirtd
systemctl start libvirtd
sudo virsh net-autostart default
sudo virsh net-start default




SYSTEMD BOOT
sudo nano /boot/loader/entries/

GRUB 
sudo nano /etc/default/grub



AMD cpu
amd_iommu=on iommu=pt ??

INTEL cpu
intel_iommu=on 
AMD gpu
video=efifb:off



GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg





sudo nano /etc/mkinitcpio.conf
#add amdgpu at end if using amd card)
vfio_pci vfio vfio_iommu_type1


mkinitcpio -P


Reboot





          REMOVE

  <graphics type="spice" autoport="yes">
    <listen type="address"/>
    <gl enable="no"/>
  </graphics>

  <audio id="1" type="none"/>

  <video>
    <model type="bochs" vram="16384" heads="1" primary="yes"/>
    <address type="pci" domain="0x0000" bus="0x05" slot="0x00" function="0x0"/>
  </video>

  <channel type="spicevmc">
    <target type="virtio" name="com.redhat.spice.0"/>
    <address type="virtio-serial" controller="0" bus="0" port="1"/>
  </channel>


            



       ANTI CHEAT BYPASS
dmidecode --type bios
dmidecode --type baseboard
dmidecode --type system

(May need to change info)

  <sysinfo type="smbios">
    <bios>
      <entry name="vendor">American Megatrends International, LLC.</entry>
      <entry name="version">1.60</entry>
      <entry name="date">07/24/2024</entry>
    </bios>
    <system>
      <entry name="manufacturer">Micro-Star International Co., Ltd.</entry>
      <entry name="product">MS-7E24</entry>
      <entry name="version">1.0</entry>
      <entry name="serial">To be filled by O.E.M.</entry>
      <entry name="uuid">cdf28472-f169-4c90-909f-72067631564f</entry>
      <entry name="sku">To be filled by O.E.M.</entry>
      <entry name="family">To be filled by O.E.M.</entry>
    </system>
  </sysinfo>


<os>
    <smbios mode="sysinfo"/>
</os>




  <acpi/>
  <apic/>
  <hyperv mode="custom">
    <relaxed state="on"/>
    <vapic state="on"/>
    <spinlocks state="on" retries="8191"/>
    <vpindex state="off"/>
    <runtime state="off"/>
    <synic state="off"/>
    <stimer state="off"/>
    <reset state="off"/>
    <vendor_id state='on' value='0123756792CD'/>
    <frequencies state="off"/>
  </hyperv>


<kvm>
<hidden state='on'/>
</kvm>



  <cpu mode='host-passthrough' check='none'>
    <topology sockets='1' dies='1' cores='8' threads='2'/>
    <feature policy='require' name='topoext'/>
  </cpu>








  <devices>
    <input type='evdev'>
      <source dev='/dev/input/by-id/usb-Logitech_G502_HERO_Gaming_Mouse_156232523633-event-mouse'/>
    </input>
    <input type='evdev'>
      <source dev='/dev/input/by-id/usb-Keychron_Keychron_C3_Pro-if02-event-kbd' grab='all' repeat='on' grabToggle='ctrl-ctrl'/>
    </input>

  </devices>


Add (PCI 0000:11:00.0) USB Controller for Corsair_Corsair_HS80_RGB_USB_Gaming_Headset




                                           (Looking glass setup)




                                            (Build dependencies)

  sudo pacman -Syu cmake gcc libgl libegl fontconfig spice-protocol make nettle pkgconf binutils \
            libxi libxinerama libxss libxcursor libxpresent libxkbcommon wayland-protocols \
            ttf-dejavu libsamplerate






download the source code as a zip file, simply unzip and cd into the new directory.

mkdir client/build
cd client/build
cmake ../
make
sudo make install



sudo nano /etc/tmpfiles.d/10-looking-glass.conf


# Type Path               Mode UID  GID Age Argument

f /dev/shm/looking-glass 0660 roofkorean kvm -


sudo chmod 666 /dev/shm/looking-glass



<shmem name='looking-glass'>
  <model type='ivshmem-plain'/>
  <size unit='M'>32</size>
</shmem>


Add spice server

Make display 'none'


<sound model='ich9'>
  <audio id='1'/>
</sound>
<audio id='1' type='spice'/>


Install spice guest tools




