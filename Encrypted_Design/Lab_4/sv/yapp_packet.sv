
//============================================================
// yapp_packet.sv
//============================================================

`ifndef YAPP_PACKET_SV
`define YAPP_PACKET_SV

// ------------------------------------------------------------
// 1. Enumeration type for parity control knob
//    Declared outside the class (package scope)
// ------------------------------------------------------------
typedef enum {GOOD_PARITY, BAD_PARITY} parity_t;

// ------------------------------------------------------------
// 2. Class Definition
// ------------------------------------------------------------
class yapp_packet extends uvm_sequence_item;

   // -------------------------
   // Properties
   // -------------------------
   rand bit [5:0] length;      // payload length (1–63 bytes)
   rand bit [1:0] addr;        // destination address (0–2 valid, 3 illegal)
        bit [7:0] parity;      // even parity byte over header + payload
   rand byte      payload[];   // dynamic array of payload bytes
   rand parity_t  parity_type; // control knob for good/bad parity
   rand int       packet_delay; // delay before sending packet (0–20 cycles)

   // -------------------------
   // Automation macros
   // -------------------------
   `uvm_object_utils_begin(yapp_packet)
      `uvm_field_int(length,       UVM_ALL_ON)
      `uvm_field_int(addr,         UVM_ALL_ON)
      `uvm_field_int(parity,       UVM_ALL_ON)
      `uvm_field_array_int(payload, UVM_ALL_ON)
      `uvm_field_enum(parity_t, parity_type, UVM_ALL_ON)
      `uvm_field_int(packet_delay, UVM_ALL_ON)
   `uvm_object_utils_end

   // -------------------------
   // Constructor
   // -------------------------
   function new(string name = "yapp_packet");
      super.new(name);
   endfunction

   // -------------------------
   // Parity calculation
   // -------------------------
   function bit [7:0] calc_parity();
      bit [7:0] temp_parity = 8'h00;
      int i;

      // Include header byte (addr in LSBs, length in MSBs)
      temp_parity ^= {length, addr};

      // Include payload bytes
      foreach (payload[i]) begin
         temp_parity ^= payload[i];
      end

      return temp_parity; // XOR gives even bitwise parity if GOOD_PARITY
   endfunction

   // -------------------------
   // Post-randomize hook
   // -------------------------
   function void post_randomize();
      // Match payload size to length
      payload = new[length];
      foreach (payload[i]) begin
         payload[i] = $urandom_range(0, 255);
      end

      if (parity_type == GOOD_PARITY)
         parity = calc_parity();
      else
         parity = calc_parity() ^ 8'h01; // flip a bit for bad parity
   endfunction

   // -------------------------
   // Constraints
   // -------------------------
   constraint c_addr_valid    { addr inside {[0:2]}; }   // 3 is illegal
   constraint c_length_valid  { length inside {[1:63]}; }
   constraint c_payload_size  { payload.size() == length; }
   constraint c_parity_dist   { parity_type dist {GOOD_PARITY := 5, BAD_PARITY := 1}; }
   constraint c_delay_range   { packet_delay inside {[0:20]}; }

endclass : yapp_packet

// -------------------------
// Subclass: short_yapp_packet
// -------------------------
class short_yapp_packet extends yapp_packet;

   // Register with factory
   `uvm_object_utils(short_yapp_packet)

   // Constructor
   function new(string name = "short_yapp_packet");
      super.new(name);
   endfunction

   // Additional constraints
   constraint c_short_length { length < 15; }
   constraint c_no_addr_2    { addr != 2;   }

endclass : short_yapp_packet


`endif // YAPP_PACKET_SV

