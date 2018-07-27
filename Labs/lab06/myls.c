// myls.c ... my very own "ls" implementation

#include <stdlib.h>
#include <stdio.h>
#include <bsd/string.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>
#include <grp.h>
#include <pwd.h>
#include <sys/stat.h>
#include <sys/types.h>

#define MAXDIRNAME 100
#define MAXFNAME   200
#define MAXNAME    20

char *rwxmode(mode_t, char *);
char *username(uid_t, char *);
char *groupname(gid_t, char *);

int main(int argc, char *argv[])
{
   // string buffers for various names
   char dirname[MAXDIRNAME];
   char uname[MAXNAME+1]; // UNCOMMENT this line
    char gname[MAXNAME+1]; // UNCOMMENT this line
   char mode[MAXNAME+1]; // UNCOMMENT this line

   // collect the directory name, with "." as default
   if (argc < 2)
      strlcpy(dirname, ".", MAXDIRNAME);
   else
      strlcpy(dirname, argv[1], MAXDIRNAME);

   // check that the name really is a directory
   struct stat info;
   if (stat(dirname, &info) < 0)
      { perror(argv[0]); exit(EXIT_FAILURE); }
   if ((info.st_mode & S_IFMT) != S_IFDIR)
      { fprintf(stderr, "%s: Not a directory\n",argv[0]); exit(EXIT_FAILURE); }

   // open the directory to start reading
    DIR *df; // UNCOMMENT this line
   // ... TODO ...
    df = opendir(dirname);
    if(df == NULL){
      printf("Error! Unable to open directory.\n");
      exit(0);
    }

   // read directory entries
    struct dirent *entry; // UNCOMMENT this line
   // ... TODO ...
    entry = readdir(df);
    struct stat sb;
    while((entry = readdir(df)) != NULL){
      if(entry->d_name[0] == '.'){
        continue;
      }
      //else
      char temp[MAXDIRNAME]; // create temp string
      memset(temp, 0, sizeof(temp)); // set temp string to 0
      strcpy(temp, dirname);  // copies dirname
      temp[strlen(dirname)] = '/';  // adds a slash on the end of dirname
      strcat(temp, entry->d_name); // adds filename to end of directory to make sure stat knows the path to the file i.e. temp = path/to/file/filename 
      temp[strlen(dirname)] = '\0'; // add a null terminator to end
      if(lstat(temp, &sb) == -1){
        perror("state");
        exit(0);
      }
      printf("%s  %-8.8s  %-8.s %8lld %s\n",
        rwxmode(sb.st_mode, mode),
        username(sb.st_uid, uname),
        groupname(sb.st_gid, gname),
        (long long)sb.st_size, entry->d_name);
    }
   // finish up
    closedir(df); // UNCOMMENT this line
   return EXIT_SUCCESS;
}

// convert octal mode to -rwxrwxrwx string
char *rwxmode(mode_t mode, char *str)
{
   // ... TODO ...
   for(int i=0; i<12; i++){
     str[i] = '-';
   }
   if(S_ISREG(mode)){
     str[0] = '-';
   }else if(S_ISDIR(mode)){
     str[0] = 'd';
   }else if(S_ISLNK(mode)){
     str[0] = 'l';
   }else{
     str[0] = '?';
   }

   str[1] = mode & S_IRUSR ? 'r' : '-';
   str[2] = mode & S_IWUSR ? 'w' : '-';
   str[3] = mode & S_IXUSR ? 'x' : '-';
   str[4] = mode & S_IRGRP ? 'r' : '-';
   str[5] = mode & S_IWGRP ? 'w' : '-';
   str[6] = mode & S_IXGRP ? 'x' : '-';
   str[7] = mode & S_IROTH ? 'r' : '-';
   str[8] = mode & S_IWOTH ? 'w' : '-';
   str[9] = mode & S_IXOTH ? 'x' : '-';
   str[10] = '\0';
   return str;
}

// convert user id to user name
char *username(uid_t uid, char *name)
{
   struct passwd *uinfo = getpwuid(uid);
   if (uinfo == NULL)
      snprintf(name, MAXNAME, "%d?", (int)uid);
   else
      snprintf(name, MAXNAME, "%s", uinfo->pw_name);
   return name;
}

// convert group id to group name
char *groupname(gid_t gid, char *name)
{
   struct group *ginfo = getgrgid(gid);
   if (ginfo == NULL)
      snprintf(name, MAXNAME, "%d?", (int)gid);
   else
      snprintf(name, MAXNAME, "%s", ginfo->gr_name);
   return name;
}
