/* ============================================================
 * Control compile time options.
 * ============================================================
 *
 * Compile time options have moved to config.mk.
 */


/* ============================================================
 * Compatibility defines
 *
 * Generally for Windows native support.
 * ============================================================ */
#ifdef WIN32
#define snprintf sprintf_s
#define strcasecmp strcmpi
#define strtok_r strtok_s
#define strerror_r(e, b, l) strerror_s(b, l, e)
#endif
#ifndef __APPLE__
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;
#endif