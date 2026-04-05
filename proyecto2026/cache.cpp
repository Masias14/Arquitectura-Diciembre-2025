#include "cacheDeclaracion.h"
#include <stdio.h>
// Contador global para LRU
int tiempoGlobal = 0;

// implementacion de la cache 

Cache::Cache(std::string nombre, CacheConfig config) {
    this->nombre = nombre;
    this->hitTime = config.hitTime;
    this->hits = 0;
    this->misses = 0;
    
    int numLines = config.size / config.lineSize;
    
    if (config.associativity == 0) {
        numSets = 1;
        numWays = numLines;
    } else {
        numWays = config.associativity;
        numSets = numLines / numWays;
    }
    
    sets.resize(numSets, std::vector<Linea>(numWays));
    
    for (int i = 0; i < numSets; i++) {
        for (int j = 0; j < numWays; j++) {
            sets[i][j].valid = false;
            sets[i][j].lastUsed = 0;
        }
    }
    
    std::cout << "Cache " << nombre << " creada: " 
              << numSets << " sets x " << numWays << " vias" << std::endl;
}

int Cache::getSetIndex(Address addr) {
    int blockSize = 64; // Tamaño de bloque fijo
    int blockAddr = addr / blockSize;
    return blockAddr % numSets;
}

unsigned int Cache::getTag(Address addr) {
    int blockSize = 64;
    int blockAddr = addr / blockSize;
    return blockAddr / numSets;
}

int Cache::findLine(int setIndex, unsigned int tag) {
    for (int i = 0; i < numWays; i++) {
        if (sets[setIndex][i].valid && sets[setIndex][i].tag == tag) {
            return i;
        }
    }
    return -1;
}

int Cache::selectVictim(int setIndex) {
    int victim = 0;
    int oldest = sets[setIndex][0].lastUsed;
    
    for (int i = 1; i < numWays; i++) {
        if (sets[setIndex][i].lastUsed < oldest) {
            oldest = sets[setIndex][i].lastUsed;
            victim = i;
        }
    }
    return victim;
}

bool Cache::read(Address addr, Data& data) {
    int setIndex = getSetIndex(addr);
    unsigned int tag = getTag(addr);
    int way = findLine(setIndex, tag);
    
    if (way != -1 && sets[setIndex][way].valid) {
        // HIT
        hits++;
        data = sets[setIndex][way].data;
        sets[setIndex][way].lastUsed = ++tiempoGlobal;
        std::cout << "[HIT] " << nombre << " - Dir: 0x" << std::hex << addr << std::dec << std::endl;
        return true;
    }
    
    // MISS
    misses++;
    std::cout << "[MISS] " << nombre << " - Dir: 0x" << std::hex << addr << std::dec << std::endl;
    return false;
}

void Cache::write(Address addr, Data data) {
    int setIndex = getSetIndex(addr);
    unsigned int tag = getTag(addr);
    int way = findLine(setIndex, tag);
    
    if (way != -1 && sets[setIndex][way].valid) {
        // WRITE HIT
        hits++;
        sets[setIndex][way].data = data;
        sets[setIndex][way].lastUsed = ++tiempoGlobal;
        std::cout << "[WRITE HIT] " << nombre << " - Dir: 0x" << std::hex << addr 
                  << " Dato: 0x" << data << std::dec << std::endl;
        return;
    }
    
    // WRITE MISS - buscar espacio libre
    misses++;
    int freeWay = -1;
    for (int i = 0; i < numWays; i++) {
        if (!sets[setIndex][i].valid) {
            freeWay = i;
            break;
        }
    }
    
    if (freeWay == -1) {
        // Reemplazar
        freeWay = selectVictim(setIndex);
        std::cout << "[EVICT] " << nombre << " - Reemplazando linea" << std::endl;
    }
    
    // Colocar nueva línea
    sets[setIndex][freeWay].tag = tag;
    sets[setIndex][freeWay].data = data;
    sets[setIndex][freeWay].valid = true;
    sets[setIndex][freeWay].lastUsed = ++tiempoGlobal;
    
    std::cout << "[WRITE MISS] " << nombre << " - Dir: 0x" << std::hex << addr 
              << " Dato: 0x" << data << std::dec << std::endl;
}

void Cache::printStats() {
    std::cout << "\nEstadisticas de " << nombre << std::endl;
    std::cout << "Hits: " << hits << std::endl;
    std::cout << "Misses: " << misses << std::endl;
    std::cout << "Hit Rate: " << std::fixed << std::setprecision(2) 
              << (100.0 * hits / (hits + misses)) << "%" << std::endl;
}

// sistema de cache multinivel 

class CacheSystem {
private:
    Cache L1, L2, L3;
    std::unordered_map<Address, Data> memoriaPrincipal;
    int totalLatencia;
    int totalAccesos;
    
    Data leerDeMemoria(Address addr) {
        totalLatencia += 100;
        std::cout << "[MEM READ] Dir: 0x" << std::hex << addr 
                  << " Latencia: 100 ciclos" << std::dec << std::endl;
        
        if (memoriaPrincipal.find(addr) != memoriaPrincipal.end()) {
            return memoriaPrincipal[addr];
        }
        return 0;
    }
    
    void escribirEnMemoria(Address addr, Data data) {
        totalLatencia += 100;
        std::cout << "[MEM WRITE] Dir: 0x" << std::hex << addr 
                  << " Dato: 0x" << data << std::dec << std::endl;
        memoriaPrincipal[addr] = data;
    }
    
public:
    CacheSystem() : 
        L1("L1", {32*1024, 64, 8, 2}),    // 32KB, línea 64B, 8 vías, 2 ciclos
        L2("L2", {256*1024, 64, 4, 8}),   // 256KB, línea 64B, 4 vías, 8 ciclos
        L3("L3", {2*1024*1024, 64, 16, 20}), // 2MB, línea 64B, 16 vías, 20 ciclos
        totalLatencia(0), totalAccesos(0) {}
    
    Data read(Address addr) {
        totalAccesos++;
        Data data;
        
        std::cout << "\n--- READ 0x" << std::hex << addr << std::dec << " ---" << std::endl;
        
        // Buscar en L1
        if (L1.read(addr, data)) {
            totalLatencia += L1.getHitTime();
            return data;
        }
        
        // Buscar en L2
        if (L2.read(addr, data)) {
            totalLatencia += L2.getHitTime();
            L1.write(addr, data);  // Actualizar L1
            return data;
        }
        
        // Buscar en L3
        if (L3.read(addr, data)) {
            totalLatencia += L3.getHitTime();
            L2.write(addr, data);  // Actualizar L2
            L1.write(addr, data);  // Actualizar L1
            return data;
        }
        
        // Leer de memoria
        data = leerDeMemoria(addr);
        
        // Propagar a las cachés
        L3.write(addr, data);
        L2.write(addr, data);
        L1.write(addr, data);
        
        return data;
    }
    
    void write(Address addr, Data data) {
        totalAccesos++;
        
        std::cout << "\n--- WRITE 0x" << std::hex << addr 
                  << " = 0x" << data << std::dec << " ---" << std::endl;
        
        // Escribir en todas las cachés (write-through)
        L1.write(addr, data);
        L2.write(addr, data);
        L3.write(addr, data);
        
        // Escribir en memoria
        escribirEnMemoria(addr, data);
        
        totalLatencia += L1.getHitTime() + 5 + 100;
    }
    
    void printStats() {
        std::cout << "\nESTADISTICAS GLOBALES" << std::endl;
        
        L1.printStats();
        L2.printStats();
        L3.printStats();
        
        std::cout << "\nMEMORIA PRINCIPAL" << std::endl;
        std::cout << "Datos almacenados: " << memoriaPrincipal.size() << " direcciones" << std::endl;
        
        std::cout << "\nLATENCIA TOTAL" << std::endl;
        std::cout << "Accesos: " << totalAccesos << std::endl;
        std::cout << "Latencia total: " << totalLatencia << " ciclos" << std::endl;
        if (totalAccesos > 0) {
            std::cout << "Latencia promedio: " << (double)totalLatencia / totalAccesos << " ciclos" << std::endl;
        }
    }
};
// funcion main 

int main() {
    std::cout << "\nSISTEMA DE CACHE MULTINIVEL (L1-L2-L3)" << std::endl;
    CacheSystem cache;
    
    // Prueba 1: Escrituras y lecturas básicas
    std::cout << "\nTEST 1: Operaciones Basicas" << std::endl;
    cache.write(0x1000, 0x1234);
    cache.write(0x2000, 0x5678);
    cache.read(0x1000);
    cache.read(0x2000);
    cache.read(0x3000);  // Esto debería ser miss
    
    // Prueba 2: Localidad espacial
    std::cout << "\nTEST 2: Localidad Espacial" << std::endl;
    for (int i = 0; i < 10; i++) {
        cache.write(0x4000 + i * 4, 0xAAAA);
    }
    for (int i = 0; i < 10; i++) {
        cache.read(0x4000 + i * 4);
    }
    
    // Prueba 3: Localidad temporal
    std::cout << "\nTEST 3: Localidad Temporal" << std::endl;
    for (int i = 0; i < 5; i++) {
        cache.read(0x5000);
        cache.write(0x5000, 0xBBBB);
    }
    
    // Estadísticas finales
    cache.printStats();
    
    return 0;
}