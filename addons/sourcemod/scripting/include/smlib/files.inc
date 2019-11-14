#if defined _smlib_files_included
	#endinput
#endif
#define _smlib_files_included

#include <sourcemod>
#include <sdktools_stringtables>
#include <smlib/arrays>

/**
 * Gets the Base name of a path.
 * Examples:
 * blub.txt -> "blub.txt"
 * /sourcemod/extensions/example.ext.so -> "example.ext.so"
 *
 * @param path			File path
 * @param buffer		String buffer array
 * @param size			Size of string buffer
 * @noreturn
 */
stock bool:File_GetBaseName(const String:fPath[], String:buffer[], size)
{	
	if (fPath[0] == '\0') {
		buffer[0] = '\0';
		return;
	}
	
	new pos_start = FindCharInString(fPath, '/', true);
	
	if (pos_start == -1) {
		pos_start = FindCharInString(fPath, '\\', true);
	}
	
	pos_start++;
	
	strcopy(buffer, size, fPath[pos_start]);
}

/**
 * Gets the Directory of a path (without the file name).
 * Does not work with "." as the path.
 * Examples:
 * blub.txt -> "blub.txt"
 * /sourcemod/extensions/example.ext.so -> "example.ext.so"
 *
 * @param path			File path
 * @param buffer		String buffer array
 * @param size			Size of string buffer
 * @noreturn
 */
stock bool:File_GetDirName(const String:fPath[], String:buffer[], size)
{	
	if (fPath[0] == '\0') {
		buffer[0] = '\0';
		return;
	}
	
	new pos_start = FindCharInString(fPath, '/', true);
	
	if (pos_start == -1) {
		pos_start = FindCharInString(fPath, '\\', true);
		
		if (pos_start == -1) {
			buffer[0] = '\0';
			return;
		}
	}
	
	strcopy(buffer, size, fPath);
	buffer[pos_start] = '\0';
}

/**
 * Gets the File name of a path.
 * blub.txt -> "blub"
 * /sourcemod/extensions/example.ext.so -> "example.ext"
 *
 * @param path			File path
 * @param buffer		String buffer array
 * @param size			Size of string buffer
 * @noreturn
 */
stock bool:File_GetFileName(const String:fPath[], String:buffer[], size)
{	
	if (fPath[0] == '\0') {
		buffer[0] = '\0';
		return;
	}
	
	File_GetBaseName(fPath, buffer, size);
	
	new pos_ext = FindCharInString(buffer, '.', true);

	if (pos_ext != -1) {
		buffer[pos_ext] = '\0';
	}
}

/**
 * Gets the Extension of a file.
 * Examples:
 * blub.inc.txt -> "txt"
 * /sourcemod/extensions/example.ext.so -> "so"
 *
 * @param fPath			fPath String
 * @param buffer		String buffer array
 * @param size			Max length of string buffer
 * @noreturn
 */
stock File_GetExtension(const String:fPath[], String:buffer[], size)
{
	new extpos = FindCharInString(fPath, '.', true);
	
	if (extpos == -1) {
		buffer[0] = '\0';
		return;
	}

	strcopy(buffer, size, fPath[++extpos]);
}

/**
 * Adds a fPath to the downloadables network string table.
 * This can be a file or directory and also works recursed.
 * You can optionally specify file extensions that should be ignored.
 * Bz2 and ztmp are automatically ignored.
 * It only adds files that actually exist.
 * You can also specify a wildcard * after the ., very useful for models.
 * This forces a client to download the file if they do not already have it.
 *
 * @param fPath			fPath String
 * @param recursive		Whether to do recursion or not.
 * @param ignoreExts	Optional: 2 dimensional String array.You can define it like this: new String:ignore[][] = { ".ext1", ".ext2" };
 * @param size			This should be set to the number of file extensions in the ignoreExts array (sizeof(ignore) for the example above)
 * @noreturn
 */

// Damn you SourcePawn :( I didn't want to
new String:_smlib_empty_twodimstring_array[][] = { { '\0' } };
stock File_AddToDownloadsTable(const String:fPath[], bool:recursive=true, const String:ignoreExts[][]=_smlib_empty_twodimstring_array, size=0)
{
	if (fPath[0] == '\0') {
		return;
	}

	if (FileExists(fPath)) {
		
		new String:fileExtension[4];
		File_GetExtension(fPath, fileExtension, sizeof(fileExtension));
		
		if (StrEqual(fileExtension, "bz2", false) || StrEqual(fileExtension, "ztmp", false)) {
			return;
		}
		
		if (Array_FindString(ignoreExts, size, fileExtension) != -1) {
			return;
		}

		decl String:path_new[PLATFORM_MAX_PATH];
		strcopy(path_new, sizeof(path_new), fPath);
		ReplaceString(path_new, sizeof(path_new), "//", "/");

		AddFileToDownloadsTable(path_new);
	}
	else if (recursive && DirExists(fPath)) {

		decl String:dirEntry[PLATFORM_MAX_PATH];
		new Handle:__dir = OpenDirectory(fPath);

		while (ReadDirEntry(__dir, dirEntry, sizeof(dirEntry))) {

			if (StrEqual(dirEntry, ".") || StrEqual(dirEntry, "..")) {
				continue;
			}
			
			Format(dirEntry, sizeof(dirEntry), "%s/%s", fPath, dirEntry);
			File_AddToDownloadsTable(dirEntry, recursive, ignoreExts, size);
		}
		
		CloseHandle(__dir);
	}
	else if (FindCharInString(fPath, '*', true)) {
		
		new String:fileExtension[4];
		File_GetExtension(fPath, fileExtension, sizeof(fileExtension));

		if (StrEqual(fileExtension, "*")) {

			decl
				String:dirName[PLATFORM_MAX_PATH],
				String:fileName[PLATFORM_MAX_PATH],
				String:dirEntry[PLATFORM_MAX_PATH];

			File_GetDirName(fPath, dirName, sizeof(dirName));
			File_GetFileName(fPath, fileName, sizeof(fileName));
			StrCat(fileName, sizeof(fileName), ".");

			new Handle:__dir = OpenDirectory(dirName);
			while (ReadDirEntry(__dir, dirEntry, sizeof(dirEntry))) {

				if (StrEqual(dirEntry, ".") || StrEqual(dirEntry, "..")) {
					continue;
				}

				if (strncmp(dirEntry, fileName, strlen(fileName)) == 0) {
					Format(dirEntry, sizeof(dirEntry), "%s/%s", dirName, dirEntry);
					File_AddToDownloadsTable(dirEntry, recursive, ignoreExts, size);
				}
			}

			CloseHandle(__dir);
		}
	}

	return;
}


/*
 * Adds all files/paths in the given text file to the download table.
 * Recursive mode enabled, see File_AddToDownloadsTable()
 * Comments are allowed ! Supported comment types are ; // #
 *
 * @param fPath			fPath to the .txt file.
 * @noreturn
 */
stock File_ReadDownloadList(const String:fPath[])
{
	new Handle:file = OpenFile(fPath, "r");
	
	if (file  == INVALID_HANDLE) {
		return;
	}

	new String:buffer[PLATFORM_MAX_PATH];
	while (!IsEndOfFile(file)) {
		ReadFileLine(file, buffer, sizeof(buffer));
		
		new pos;
		pos = StrContains(buffer, "//");
		if (pos != -1) {
			buffer[pos] = '\0';
		}
		
		pos = StrContains(buffer, "#");
		if (pos != -1) {
			buffer[pos] = '\0';
		}

		pos = StrContains(buffer, ";");
		if (pos != -1) {
			buffer[pos] = '\0';
		}
		
		TrimString(buffer);
		
		if (buffer[0] == '\0') {
			continue;
		}

		File_AddToDownloadsTable(buffer);
	}

	CloseHandle(file);
}

/*
 * Attempts to load a translation file and unloads the plugin if the file doesn't exist.
 *
 * @param file		Filename of the translations file (eg. <pluginname>.phrases).
 * @noreturn
 */
stock File_LoadTranslations(const String:file[])
{
	decl String:fPath[PLATFORM_MAX_PATH];
	
	Format(fPath,sizeof(fPath),"translations/%s",file);
	
	BuildPath(Path_SM, fPath, sizeof(fPath), fPath);
	
	if (FileExists(fPath)) {
		LoadTranslations(file);
		return;
	}
	
	Format(fPath,sizeof(fPath),"%s.txt",fPath);
	
	if (FileExists(fPath)) {
		LoadTranslations(file);
		return;
	}
	
	SetFailState("Unable to locate translation file (%s).",fPath);
}

/*
 * Reads the contents of a given file into a string buffer in binaey mode.
 *
 * @param fPath		fPath to the file
 * @param buffer	String buffer
 * @param size		If -1, reads until a null terminator is encountered in the file.  Otherwise, read_count bytes are read into the buffer provided.  In this case the buffer is not explicitly null terminated, and the buffer will contain any null terminators read from the file.
 * @return			Number of characters written to the buffer, or -1 if an error was encountered.
 */
stock File_ToString(const String:fPath[], String:buffer[], size)
{
	new Handle:file = OpenFile(fPath, "rb");

	if (file == INVALID_HANDLE) {
		buffer[0] = '\0';
		return -1;
	}

	new num_bytes_written = ReadFileString(file, buffer, size);
	CloseHandle(file);

	return num_bytes_written;
}

/*
 * Writes a string into a file in binary mode.
 *
 * @param file		fPath to the file
 * @param str		String to write
 * @return			True on success, false otherwise
 */
stock bool:File_StringToFile(const String:fPath[], String:str[])
{
	new Handle:file = OpenFile(fPath, "wb");

	if (file == INVALID_HANDLE) {
		return false;
	}

	new bool:success = WriteFileString(file, str, false);
	CloseHandle(file);

	return success;
}

/*
 * Copies file source to destination
 * Based on code of javalia:
 * http://forums.alliedmods.net/showthread.php?t=159895
 *
 * @param source		Input file
 * @param destination	Output file
 */
stock bool:File_Copy(const String:source[], const String:destination[])
{
	new Handle:file_source = OpenFile(source, "rb");

	if (file_source == INVALID_HANDLE) {
		return false;
	}

	new Handle:file_destination = OpenFile(destination, "wb");

	if (file_destination == INVALID_HANDLE) {
		CloseHandle(file_source);
		return false;
	}

	new buffer[32];
	new cache;

	while (!IsEndOfFile(file_source)) {
		cache = ReadFile(file_source, buffer, 32, 1);
		WriteFile(file_destination, buffer, cache, 1);
	}

	CloseHandle(file_source);
	CloseHandle(file_destination);

	return true;
}

/*
 * Recursively copies (the content) of a directory or file specified
 * by "fPath" to "destination".
 * Note that because of Sourcemod API limitations this currently does not
 * takeover the file permissions (it leaves them default).
 * Links will be resolved.
 *
 * @param fPath			Source fPath
 * @param destination	Destination directory (This can only be a directory)
 * @param stop_on_error	Optional: Set to true to stop on error (ie can't read a file)
 * @param dirMode		Optional: File mode for directories that will be created (Default = 0755), don't forget to convert FROM octal
 */
stock bool:File_CopyRecursive(const String:fPath[], const String:destination[], bool:stop_on_error=false, dirMode=493)
{
	if (FileExists(fPath)) {
		return File_Copy(fPath, destination);
	}
	else if (DirExists(fPath)) {
		return Sub_File_CopyRecursive(fPath, destination, stop_on_error, FileType_Directory, dirMode);
	}
	else {
		return false;
	}
}

static stock bool:Sub_File_CopyRecursive(const String:fPath[], const String:destination[], bool:stop_on_error=false, FileType:fileType, dirMode)
{
	if (fileType == FileType_File) {
		return File_Copy(fPath, destination);
	}
	else if (fileType == FileType_Directory) {

		if (!CreateDirectory(destination, dirMode) && stop_on_error) {
			return false;
		}

		new Handle:directory = OpenDirectory(fPath);

		if (directory == INVALID_HANDLE) {
			return false;
		}

		decl
			String:source_buffer[PLATFORM_MAX_PATH],
			String:destination_buffer[PLATFORM_MAX_PATH];
		new FileType:type;

		while (ReadDirEntry(directory, source_buffer, sizeof(source_buffer), type)) {

			if (StrEqual(source_buffer, "..") || StrEqual(source_buffer, ".")) {
				continue;
			}

			Format(destination_buffer, sizeof(destination_buffer), "%s/%s", destination, source_buffer);
			Format(source_buffer, sizeof(source_buffer), "%s/%s", fPath, source_buffer);

			if (type == FileType_File) {
				File_Copy(source_buffer, destination_buffer);
			}
			else if (type == FileType_Directory) {

				if (!File_CopyRecursive(source_buffer, destination_buffer, stop_on_error, dirMode) && stop_on_error) {
					CloseHandle(directory);
					return false;
				}
			}
		}

		CloseHandle(directory);
	}
	else if (fileType == FileType_Unknown) {
		return false;
	}

	return true;
}
