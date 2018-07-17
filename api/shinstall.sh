#!/bin/sh
#
#
#
#
#
#
#
# curl -sSfL https://simple-lang.io/api/stable_version.sim to get version by url in future

simple_lang_url="https://simple-lang.io?page=Download"
setup_url_prefix="http://10.0.2.2/simple-lang/"
temp_dir="${TMPDIR:-/tmp/}"
simple_lang_version="0.3.36"
need_tty=yes

install_simple_lang() {
	get_os_platform || return 1
	local os_platform=$return_value
	get_installation_dir $os_platform || return 1
	installation_dir=$return_value
	if [ $simple_lang_version = "not_supported_yet" ]; then 
		display_error "simple-lang not built on your platform $os_platform"
		display_error "try building simple-lang from source"
		exit 1 
	fi
	#get_temp_setup_extention $os_platform || return 1
	local setup_extension=$return_value
	local setup_file_name="simple$simple_lang_version-$os_platform"
	local setup_url="$setup_url_prefix"s"$simple_lang_version/$setup_file_name.zip"
	display "downloading $setup_file_name to $temp_dir$setup_file_name.zip ..."
	curl -sSfL "$setup_url" -o "$temp_dir$setup_file_name.zip"
	if [ -e "$temp_dir$setup_file_name.zip" ]; then 
		display "installing $setup_file_name..."
		install "$temp_dir$setup_file_name.zip" $os_platform
		
		if [ -e "$temp_dir"s"$simple_lang_version" ]; then 
			display "simple $simple_lang_version installed successfully"
			remove_temp_file "$temp_dir$setup_file_name.zip"
		fi
	else
		display_error "simple-lang not built on your platform $os_platform"
		display_error "please install from alternative source"
		display_error "visit $simple_lang_url"
	fi 
	
}

install() {
	if [ $2 = "windows_amd64" ] || [ $2 = "windows_x86" ]; then 
		unzip -o $1 -d "$installation_dir"s"$simple_lang_version" &> /dev/null
	else #if [ $2 = "linux_amd64" ] || [ $2 = "linux_x86" ]; then
		sudo dpkg -i $1
	fi
}

remove_temp_file() {
	rm -f $1
	if [ -e $1 ]; then 
		return 0
	fi
	return 1
}

display() {
	echo "simple-lang:install:script: $1"
}

display_error() {
	display "Error: $1" >&2
	exit 1
}

get_installation_dir() {
	if [ $1 = "windows_amd64" ] || [ $1 = "windows_x86" ]; then 
		return_value="C:/Simple/"
		temp_dir=$return_value
	else
		return_value="/bin/"
	fi
	
	if [ -e "$return_value" ]; then  
		display "installation directory present"
	else
		display "creating installation directory"
		mkdir $return_value &> /dev/null
	fi
}

get_os_platform() {
	  # Get OS/CPU info and store in a `myos` and `mycpu` variable.
	  local ucpu=`uname -m`
	  local uos=`uname`
	  local ucpu=`echo $ucpu | tr "[:upper:]" "[:lower:]"`
	  local uos=`echo $uos | tr "[:upper:]" "[:lower:]"`

	  case $uos in
		*linux* )
		  local myos="linux"
		  ;;
		*dragonfly* )
		  local myos="freebsd"
		  ;;
		*freebsd* )
		  local myos="freebsd"
		  ;;
		*openbsd* )
		  local myos="openbsd"
		  ;;
		*netbsd* )
		  local myos="netbsd"
		  ;;
		*darwin* )
		  local myos="macosx"
		  if [ "$HOSTTYPE" = "x86_64" ] ; then
			local ucpu="amd64"
		  fi
		  ;;
		*aix* )
		  local myos="aix"
		  ;;
		*solaris* | *sun* )
		  local myos="solaris"
		  ;;
		*haiku* )
		  local myos="haiku"
		  ;;
		*mingw* )
		  local myos="windows"
		  ;;
		*)
		  display_error "unknown operating system: $uos"
		  ;;
	  esac

	  case $ucpu in
		*i386* | *i486* | *i586* | *i686* | *bepc* | *i86pc* )
		  local mycpu="i386" ;;
		*amd*64* | *x86-64* | *x86_64* )
		  local mycpu="amd64" ;;
		*sparc*|*sun* )
		  local mycpu="sparc"
		  if [ "$(isainfo -b)" = "64" ]; then
			local mycpu="sparc64"
		  fi
		  ;;
		*ppc64* )
		  local mycpu="powerpc64" ;;
		*power*|*ppc* )
		  local mycpu="powerpc" ;;
		*mips* )
		  local mycpu="mips" ;;
		*arm*|*armv6l* )
		  local mycpu="arm" ;;
		*aarch64* )
		  local mycpu="arm64" ;;
		*)
		  display_error "unknown processor: $ucpu"
		  ;;
	  esac

	  return_value="$myos"_"$mycpu"
}

install_simple_lang