#!/bin/bash
#
#
#
#
#
#
#
# curl -sSfL https://simple-lang.io/api/stable_version.sim to get version by url in future

simple_lang_host=http://localhost/simple-lang.io
simple_lang_url="$simple_lang_host/download/"
setup_query_url="$simple_lang_host/simple-lang.io/api/downloads.sim"
temp_dir="${TMPDIR:-/tmp/}"
simple_lang_version="0.3.36"
need_tty=yes
setup_extension="zip"

install_simple_lang() {
	get_os_platform || return 1
	local os_platform=$return_value
	get_installation_dir $os_platform || return 1
	installation_dir=$return_value
	#echo $installation_dir-$os_platform
	#$(fetch_setup_info "$os_platform" "extension")
	local setup_file_name=$(fetch_setup_info "$os_platform" "file_name")
	simple_lang_version=$(fetch_setup_info "$os_platform" "version")
	local setup_url=$(fetch_setup_info "$os_platform" "download_link") 
	if [ "$simple_lang_version" = "" ] || [ "$simple_lang_version" = "not_supported_yet" ]; then 
		display "simple-lang not yet built for your platform: $os_platform"
		display "try building simple-lang from source"
		display_error "visit $simple_lang_url"
		exit 1 
	fi
	curl -sSfL "$setup_url" -o "$temp_dir$setup_file_name.zip" -L
	if [ -e "$temp_dir$setup_file_name.zip" ]; then 
		display "installing $setup_file_name..."
		install "$temp_dir$setup_file_name.zip" $os_platform
		local installation_value=$return_value
		
		if [ $installation_value = "true" ]; then 
			display "simple $simple_lang_version installed successfully"
			remove_temp_file "$temp_dir$setup_file_name.zip"
		else 
			display_error "simple $simple_lang_version installation failed"
		fi
	else
		display "an installation zip archive is not available for your platform"
		display "please install from alternative source"
		display_error "visit $simple_lang_url"
		exit 1
	fi 
	
}

fetch_setup_info() {
	response=$(curl -sSfL -X GET "$setup_query_url?os=$1&query=$2&type=$setup_extension")
	echo "$response"
}

install() {
	if [ $2 = "windows_amd64" ] || [ $2 = "windows_x86" ]; then 
		unzip -o $1 -d "$installation_dir"s"$simple_lang_version" &> /dev/null
		if [ -e "$temp_dir"s"$simple_lang_version" ]; then 
			return_value="true"
			return 1
		fi
	else #if [ $2 = "linux_amd64" ] || [ $2 = "linux_x86" ]; then
		sudo dpkg -i $1
		ldconfig -p | grep libsimple >/dev/null 2>&1 && {
			return_value="true"
			return 1
		} || {
			return_value="false"
			return 0
		}
	fi
	return_value="false"
	return 0
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
		if [ -e "$return_value" ]; then  
			display "installation directory present"
		else
			display "creating installation directory"
			mkdir $return_value &> /dev/null
		fi
		#return_value="/bin/"
	else
		return_value="$PREFIX/bin/"
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
		  setup_extension="deb"
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
		  setup_extension="zip"
		  ;;
		*mingw* )
		  local myos="windows"
		  setup_extension="zip"
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