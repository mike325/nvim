TARGET   = main
SOURCES  = main.cpp
CXXFLAGS =  -std=c++17               \
			-O2                      \
			-Wall                    \
			-Wextra                  \
			-Wno-c++98-compat        \
			-Wshadow                 \
			-Wnon-virtual-dtor       \
			-Wold-style-cast         \
			-Wcast-align             \
			-Wunused                 \
			-Woverloaded-virtual     \
			-Wpedantic               \
			-Wconversion             \
			-Wsign-conversion        \
			-Wnull-dereference       \
			-Wdouble-promotion       \
			-Wmisleading-indentation \
			-Wduplicated-cond        \
			-Wduplicated-branches    \
			-Wlogical-op             \
			-Wuseless-cast           \
			-Wformat=2               \
			-g
INCLUDE  =
LDFLAGS  =

OBJS     = $(addprefix build/,$(SOURCES:.cpp=.o))
DEPS     = $(OBJS:.o=.d)

all: $(TARGET)

build/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c -MMD -o $@ $<

$(TARGET): $(OBJS)
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS) $(LDFLAGS)

-include $(DEPS)

.PHONY: all clean

clean:
	@rm -rvf $(TARGET) $(OBJS) $(DEPS)
