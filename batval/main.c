#include <stdio.h>
#include <string.h>
#include <dirent.h>
#include <stdlib.h>

//Define a linked list for our battery entries names
struct dir {
    int key;
    //dir name is actually a pointer returned from a function call.
    char *data;
    struct dir *next;
};

//Init first and current entries as NULL
struct dir *head = NULL;
struct dir *current = NULL;

//Insert Into Linked list
void insert_batttery_dir(int key, char *data)
{

    struct dir *link = (struct dir*) malloc(sizeof(struct dir));
    link->key = key;
    link->data = data;

    //Put Value At Top Of The Linked List
    link->next = head;

    //Shift Across
    head = link;
    
}

int find_batteries(char *supply_dir)
{
    //Find All The Battery Entries Given A Directory to Lookup, Append To A Linked List.
    DIR *d;
    struct dirent *dir;
    int index = 0;
    char directory;
    d = opendir(supply_dir);
    if (d) 
    {
        while ((dir = readdir(d)) != NULL ) {
            //Strip out this current dir, and parent dir.
            if (strcmp(dir->d_name, ".") != 0 && strcmp(dir->d_name, "..") != 0)
            {
                //Put Dir name and index value into linked list
                index++;
                insert_batttery_dir(index, dir->d_name);
            }
        }
        closedir(d);
    }
    else
    {
        printf("%s\n", "Error: power supply directory not found, exiting.");
        return 1;
    }


    if (index > 0)
    {
        printf("%d %s", index, "Batteries found.\n");
        return 0;
    }
    else
    {
        printf("%s", "Error, No Batteries found.\n");
        return 1;
    }
}

int main(void) {
    char supply_dir[30] = "/sys/class/power_supply/";
    //Build A List of Directories In /sys/class/power_supply
    if (find_batteries(supply_dir) != 0 )
    {
        return 1;
    }
    
    //Create local var pointing to our data in memory
    struct dir *ptr = head;
    //Create a variable called tmp with no value to initialise our position in the linked list
    //I couldnt think of a better way...
    void *tmp;
    //Loop Over Each Battery Entry Printing Name:
    while(ptr != NULL) {
        printf("%s\n", ptr->data);
        tmp = ptr;
        //Move to next entry in linked list
        ptr = ptr->next;
        //Free our previous position - for every malloc we must free!
        free(tmp);
    }

    /*
    TODO - delve deeper into /sys/class/power_supply/$battery/
    At the moment we just return a bunch of battery names, which is a bit crap, inside this dir are lots of files such as:

    capacity
    energy_full
    type
    voltage now

    Which the kernel writes to for us, we should do some maths to work out battery % currently, for each and make a nice linked list containing each batterys info.
    if it were JSON it'd look something like:

    {
        "battery0": {
            "capacity": 3000,
            "battery_percent": 34,
            ""
        }
    }

    */
    return 0;
}