# Sonatype Nexus 3

Nexus Repository Manager (NXRM) 3

## Configuration

1.) Default is to run on port 8081.  
2.) Default credentials: admin/admin123  
3.) Installs to /opt/sonatype/nexus in container.  
4.) Persistent data directory is /nexus-data. This is where the nfs-volume is mounted to. Needs to be writable by Nexus-process having UID 200.  
5.) JVM-Arguments can be passed using env-variable INSTALL4J_ADD_VM_PARAMS. This is a string, passed to Install4J startup script. Default values are:  
    -Xms1200m -Xmx1200m -XX:MaxDirectMemorySize=2g -Djava.util.prefs.userRoot=${NEXUS_DATA}/javaprefs  
    To maintain an installed Nexus Repository License -Djava.util.prefs.userRoot can be set to a persistent path, to maintain installed licenses, when the container is restarated.  
6.) Context path for Nexus can be set via NEXUS_CONTEXT. Default: /  
