TARGET   := main

CXXFLAGS := -std=c++17               \
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
			-Wdouble-promotion       \
			-Wformat=2               \
			-g

BUILD_DIR := build

SRCS_DIR := src
SRCS     := main.cpp

INC_DIRS  := include
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

LDFLAGS :=

OBJS := $(addprefix $(BUILD_DIR)/,$(SRCS_DIR)/$(SRCS:.cpp=.o))
DEPS := $(OBJS:.o=.d)

all: $(BUILD_DIR)/$(TARGET)

$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $(INC_FLAGS) -c -MP -MMD -o $@ $<

$(BUILD_DIR)/$(TARGET): $(OBJS)
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -o  $(BUILD_DIR)/$(TARGET) $(OBJS) $(LDFLAGS)

-include $(DEPS)

.PHONY: all clean

clean:
	@rm -rvf $(BUILD_DIR) compile_flags.txt

compile_flags:
	$(shell echo $(CXXFLAGS) | tr ' ' '\n' > compile_flags.txt)
