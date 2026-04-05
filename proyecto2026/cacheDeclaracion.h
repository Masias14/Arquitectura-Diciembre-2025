#ifndef CACHE_H
#define CACHE_H

#include <iostream>
#include <vector>
#include <unordered_map>
#include <list>
#include <iomanip>

using Address = unsigned int;
using Data = unsigned int;

// Configuración de la caché
struct CacheConfig {
    int size;           // Tamaño en bytes
    int lineSize;       // Tamaño de línea en bytes
    int associativity;  // Asociatividad
    int hitTime;        // Latencia de hit en ciclos
};

class Cache {
private:
    struct Linea {
        unsigned int tag;
        Data data;
        bool valid;
        int lastUsed;
    };
    
    std::string nombre;
    std::vector<std::vector<Linea>> sets;
    int numSets;
    int numWays;
    int hitTime;
    int hits;
    int misses;
    
    int getSetIndex(Address addr);
    unsigned int getTag(Address addr);
    int findLine(int setIndex, unsigned int tag);
    int selectVictim(int setIndex);
    
public:
    Cache(std::string nombre, CacheConfig config);
    bool read(Address addr, Data& data);
    void write(Address addr, Data data);
    void printStats();
    int getHitTime() { return hitTime; }
    int getHits() { return hits; }
    int getMisses() { return misses; }
};

#endif