struct RamPage {
    unsigned int value = 0;
    RamPage() = default;
    template<typename T>
    explicit RamPage(T v) : value(static_cast<unsigned int>(v)) {}
};
RamPage test(int x) { return (RamPage)x; }
RamPage test2(unsigned long long x) { return (RamPage)x; }
int main() { return 0; }
