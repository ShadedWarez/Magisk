Here is the exact command syntax from the Maikyxd/val-protocol README so you have it saved for when you get to your computer:

1. Install Python Dependencies

Open Command Prompt inside your extracted val-protocol folder (C:\MotoRoot\val-protocol\) and install the required packages (Python 3.11+ 64-bit is recommended):

python -m pip install -r requirements.txt



2. Patch lk.img With lk_auto_patch.py

Run the auto-patcher against your untouched lk.img using the unlock-serial-nvdata preset and any custom secret string you choose:

python lk_auto_patch.py "lk.img" -o "lk_patched.img" --preset unlock-serial-nvdata --key-token-secret "YourSecret" --erase-partition frp


• How the unlock key works: You do not hardcode your phone's serial number into the image. The patched lk_patched.img reads your serial number at runtime, and lk_auto_patch.py prints out your device's 20-character unlock key (or you can generate it with lk_keygen.py using the same --key-token-secret and your Fastboot serial number).

3. Flash & Unlock via Fastboot

From your platform-tools folder (with lk_patched.img copied inside), check your active slot (a or b), flash the patched bootloader, reboot back into Fastboot, and unlock:


fastboot getvar current-slot
fastboot flash lk_a lk_patched.img
fastboot reboot bootloader
fastboot oem unlock YOUR_20_CHAR_KEY


(Note: If current-slot returns b, flash lk_b instead of lk_a.)
Would you like me to save the Magisk post-root debloat commands for removing com.motorola.paks permanently once you have root access?
